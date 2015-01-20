<?php
include_once 'Http.php';

/**
 * Class Aws
 */
class Aws {

    /**
     * @var string
     */
    private $region;

    /**
     * @var string
     */
    private $profile;

    /**
     * @var array
     */
    private $filters;

    /**
     * @var string
     */
    private $base_command;

    /**
     * @param string $environment
     * @param string $region
     * @param string $profile
     * @param array $filters
     */
    function __construct($environment = 'staging', $region = 'us-east-1', $profile = 'default', $filters = array())
    {
        $this->environment  = $environment;
        $this->region       = $region;
        $this->profile      = $profile;
        //Default filters
        $this->filters      = array_merge([
                        'instance-state-code' => '16,0',
                        'tag:environment' => $this->environment
                    ], $filters);

        $this->base_command = "aws ec2 --region " . $this->region . " --profile " . $this->profile;
    }

    /**
     * Prepare an aws command before running it
     * @param string $command
     * @param array $options
     * @param array|boolean $filters
     * @return string
     */
    private function buildCommand($command = 'describe-instances', $options = array(), $filters = array()){
        $command = $this->base_command . ' ' . $command;

        foreach($options as $name => $values)
            $command .= ' ' . $name . ' ' . $values;

        if($filters !== false){
            $command .= ' --filter';
            $filters = array_merge($this->filters, $filters);
            foreach($filters as $name => $values)
                $command .= " 'Name=" . $name . ",Values=" . $values . "'";
        }

        return $command;
    }

    /**
     * Run a aws command
     * @param string $command
     * @param array $options
     * @param array|boolean $filters
     * @return array
     */
    private function runCommand($command = 'describe-instances', $options = array(), $filters = array())
    {
        if( !in_array($this->environment, array('testing', 'development')) ) {
            exec($this->buildCommand($command, $options, $filters), $response, $exit_code);
            $response = @json_decode(implode(PHP_EOL, $response), true) ?: false;
            return ['response' => $response, 'exit_code' => $exit_code];
        } else {
            //If we are on a development environment, use a mocked json file
            $data_file = file_get_contents(realpath(dirname(__FILE__)) . '/../data/mocked_stack.json');
            return ['response' => json_decode($data_file, true), 'exit_code' => 0];
        }
    }

    /**
     * Get a group of instances by their tags
     * @param $tag_name
     * @param $tag_value
     * @return array
     */
    public function getInstancesByTag($tag_name, $tag_value){
        $filters = array("tag:" . $tag_name => $tag_value);
        $result = $this->runCommand('describe-instances', array(), $filters);
        return @$result['response']['Reservations'] ?: array();
    }

    /**
     * Update and instance tag using the aws CLI
     * @param $instance_id
     * @param $tag_name
     * @param $tag_value
     * @return bool
     */
    public function updateInstanceTag($instance_id, $tag_name, $tag_value)
    {
        $options = array(
            '--resources' => $instance_id,
            '--tags' => "Key=" . $tag_name . ",Value=" . $tag_value
        );
        $result = $result = $this->runCommand('create-tags', $options, false);
        return $result['exit_code'] == 0;
    }

    /**
     * Get current instance from aws
     * @return array
     */
    public function getCurrentInstance()
    {
        $reservations = $this->getInstancesByTag('opsworks:instance', gethostname());
        return @$reservations[0]['Instances'][0] ?: array();
    }

    /**
     * @param string $tag_name
     * @param array $tags
     * @return string
     */
    public function getTag($tag_name, $tags)
    {
        if (is_array($tags)) {
            foreach ($tags as $key => $tag) {
                if($tag['Key'] == $tag_name)
                    return $tag['Value'];
            }
        }
        return null;
    }

    /**
     * Get a list of ips from an instance array
     * @param array $reservations
     * @return array
     */
    public function getIpFromInstances($reservations = array()){
        $ips = array();
        foreach($reservations as $reservation)
            if(isset($reservation['Instances']))
                foreach($reservation['Instances'] as $instance)
                    if(isset($instance['PrivateIpAddress']) && !empty($instance['PrivateIpAddress']))
                        $ips[] = $instance['PrivateIpAddress'];

        return $ips;
    }
}