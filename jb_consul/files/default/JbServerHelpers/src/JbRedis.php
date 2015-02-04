<?php

/**
 * Class JbRedis
 */
class JbRedis
{

    /**
     * Ip of the redis service
     * @var string
     */
    private $ip;
    /**
     * Port of the redis service
     * @var int
     */
    private $port;
    /**
     * Path to redis configuration dir
     * @var string
     */
    private $config_dir;
    /**
     * String with the configurations loaded from the config file
     * @var
     */
    private $config;
    /**
     * Name of the running sentinel service
     * @var string
     */
    private $sentinel_name;
    /**
     * String with the sentinel configurations loaded from the config file
     * @var
     */
    private $sentinel_config;
    /**
     * Quorum needed by sentinel
     * @var int
     */
    private $sentinel_quorum;

    /**
     * @param string $ip
     * @param int $port
     * @param string $config_dir
     * @param string $sentinel_name
     * @param int $sentinel_quorum
     */
    function __construct($ip = '127.0.0.1', $port = 6379, $config_dir = '/etc/redis', $sentinel_name = '', $sentinel_quorum = 1)
    {
        $this->ip = $ip;
        $this->port = $port;
        $this->config_dir = $config_dir;
        $this->sentinel_name = $sentinel_name;
        $this->sentinel_quorum = $sentinel_quorum;
    }

    /**
     * Kill the current process using the port
     * @param  int $port Service port
     */
    private function releaseServicePort($port = null)
    {
        $port = $port ?: $this->port;
        exec('fuser ' . $port . '/tcp', $output, $status);
        if($status != 0)
            exec('fuser -k ' . $port . '/tcp');
    }

    /**
     * Load the configuration from a config file
     * @param null $config_file
     */
    public function loadConfiguration($config_file = null)
    {
        $config_file = $config_file ?: $this->port . '.conf';
        $this->config = file_get_contents($this->config_dir . '/' . $config_file);
    }

    /**
     * Get the current loaded configurations
     * @return mixed
     */
    public function getConfiguration()
    {
        return $this->config;
    }

    /**
     * Save the loaded configurations into a config file
     * @param null $config
     * @param null $config_file
     * @return bool
     */
    public function saveConfiguration($config = null, $config_file = null)
    {
        $config_file = $config_file ?: $this->port . '.conf';
        $config = $config ?: $this->config;
        $saved = file_put_contents($this->config_dir . '/' . $config_file, trim($config)) != false;
        $this->loadConfiguration($config_file);
        return $saved;
    }

    /**
     * Set a redis master
     * @param $master_ip
     * @param $master_port
     */
    public function setMaster($master_ip, $master_port)
    {
        if (!$this->config)
            $this->loadConfiguration();
        //Remove any other master currently in the configuration
        $this->config = preg_replace("/^slaveof.*/m", null, $this->config);
        $this->config .= PHP_EOL . "slaveof " . $master_ip . " " . $master_port;

        $this->config = preg_replace("/^#slaveof.*/m", null, $this->config);
        $this->config .= PHP_EOL . "#slaveof " . $master_ip . " " . $master_port;
    }

    /**
     * Start the redis service
     * @param null $service_suffix
     * @param boolean $force With force it will stop any process using the port of the service
     */
    public function startService($service_suffix = null, $force = true)
    {

        if($force)
            $this->releaseServicePort();
        $service_suffix = $service_suffix ?: $this->port;
        exec('sudo service redis' . $service_suffix . ' stop');
        exec('sudo service redis' . $service_suffix . ' start');
    }

    /**
     * Get the loaded sentinel configurations
     * @return mixed
     */
    public function getSentinelConfiguration()
    {
        return $this->sentinel_config;
    }

    /**
     * Load sentinel configurations from a config file
     * @param null $config_file
     */
    public function loadSentinelConfiguration($config_file = null)
    {
        $config_file = $config_file ?: 'sentinel_' . $this->sentinel_name . '.conf';
        $this->sentinel_config = file_get_contents($this->config_dir . '/' . $config_file);
    }

    /**
     * Set a redis master on the sentinel configurations
     * @param $master_ip
     * @param $master_port
     */
    public function setSentinelMonitor($master_ip, $master_port)
    {
        if (!$this->sentinel_config)
            $this->loadSentinelConfiguration();
        //Remove any other monitoring master
        $this->sentinel_config = preg_replace("/^sentinel.monitor.*/m", null, $this->sentinel_config);
        $this->sentinel_config = 'sentinel monitor sentinel_' . $this->sentinel_name . ' ' . $master_ip . ' ' . $master_port . ' ' . $this->sentinel_quorum . PHP_EOL . $this->sentinel_config;
    }

    /**
     * Save loaded sentinel configurations on a config file
     * @param null $config
     * @param null $config_file
     * @return bool
     */
    public function saveSentinelConfiguration($config = null, $config_file = null)
    {
        $config_file = $config_file ?: 'sentinel_' . $this->sentinel_name . '.conf';
        $config = $config ?: $this->sentinel_config;
        $saved = file_put_contents($this->config_dir . '/' . $config_file, trim($config)) != false;
        $this->loadSentinelConfiguration($config_file);
        return $saved;
    }

    /**
     * Execute a redis command and return the output of it
     * @param  string $command
     * @param  string $port
     * @param  string $ip
     * @return array
     */
    public function runCommand($command, $ip = null, $port = null)
    {
        $ip = $ip ?: $this->ip;
        $port = $port ?: $this->port;
        exec('redis-cli -p ' . $port . ' -h ' . $ip . ' ' . $command, $output);
        return $output;
    }
}