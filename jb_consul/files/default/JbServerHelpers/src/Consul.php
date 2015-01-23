<?php
include_once 'Http.php';

/**
 * Class Consul
 */
class Consul
{
    /**
     * @var string
     */
    private $base_url;

    /**
     * @var string
     */
    private $config_dir;

    /**
     * @var string
     */
    private $bin;

    /**
     * @var array
     */
    private $config;

    /**
     * @var array
     */
    private $services_config;

    /**
     * @var int
     */
    private $port;

    /**
     * @param string $base_url
     * @param string $config_dir
     * @param string $bin
     * @param int $port
     */
    function __construct($base_url = 'http://localhost:8500/v1', $config_dir = '/etc/consul.d', $bin = '/usr/local/bin/consul', $port = 8301)
    {
        $this->base_url = $base_url;
        $this->config_dir = $config_dir;
        $this->port = $port;
        $this->bin = $bin;
    }

    /**
     * Run a consul command on the current server
     * @param string $command
     * @return array
     */
    private function runCommand($command = 'info')
    {
        exec($this->bin . ' ' . $command, $response, $exit_code);
        return ['response' => $response, 'exit_code' => $exit_code];
    }

    /**
     * Check if the consul agent is running on the current server
     * @return bool
     */
    public function agentRunning()
    {
        $result = $this->runCommand('info');
        return $result['exit_code'] == 0;
    }

    /**
     * Reloads the agent on the current server
     * @return bool
     */
    public function reloadAgent()
    {
        $result = $this->runCommand('reload');
        return $result['exit_code'] == 0;
    }

    /**
     * Join another consul server.
     * If the persist flag is true, the joined server will be added to the retry_list on the config file
     * @param $server_ip
     * @param bool $persist
     * @return bool
     */
    public function joinServer($server_ip, $persist = false){
        $result = $this->runCommand('join ' . $server_ip . ':' . $this->port);
        if($result['exit_code'] == 0 && $persist)
            $this->addServerToJoinList($server_ip);
        return $result['exit_code'] == 0;
    }

    /**
     * Join multiple consul servers
     * @param $servers_ip
     * @param bool $persist
     * @return bool
     */
    public function joinMultipleServers($servers_ip, $persist = false)
    {
        $result = $this->runCommand('join ' . implode(':' . $this->port . ' ', $servers_ip) . ':' . $this->port);
        if($result['exit_code'] == 0 && $persist)
            $this->addServerListToJoinList($servers_ip);
        return $result['exit_code'] == 0;
    }

    /**
     * Load the configuration from a config file
     * @param string $file_name
     */
    public function loadConfiguration($file_name = 'default.json')
    {
        $contents = file_get_contents($this->config_dir . '/' . $file_name);
        $this->config = json_decode($contents, true);
    }

    /**
     * Saves the consul configuration on a config file
     * @param array $consul_config
     * @param string $file_name
     */
    public function saveConfiguration($consul_config = null, $file_name = 'default.json')
    {
        $consul_config = $consul_config ?: $this->config;
        file_put_contents($this->config_dir . '/' . $file_name, str_replace("\\",'',json_encode($consul_config, JSON_PRETTY_PRINT)));
        //Reloads the new configuration in case it was changed from a different source
        $this->loadConfiguration($file_name);
    }

    /**
     * Get the current loaded consul configuration
     * @return array
     */
    public function getConfiguration()
    {
        return $this->config;
    }

    /**
     * Load a service configuration from a config file
     * @param $service_name
     * @param string $service_config_file
     */
    public function loadServiceConfiguration($service_name, $service_config_file = null)
    {
        $service_config_file = $service_config_file ?: $service_name . '.json';
        $contents = file_get_contents($this->config_dir . '/' . $service_config_file);
        $this->services_config[$service_name] = json_decode($contents, true);
    }

    /**
     * Save a specific service configuration on a config file
     * @param string $service_name
     * @param null|string $service_config_file
     * @param array $service_config
     */
    public function saveServiceConfiguration($service_name, $service_config_file = null, $service_config = null)
    {
        $service_config_file = $service_config_file ?: $service_name . '.json';
        $service_config = $service_config ?: $this->services_config[$service_name];
        file_put_contents($this->config_dir . '/' . $service_config_file, str_replace("\\",'',json_encode($service_config, JSON_PRETTY_PRINT)));
        $this->loadServiceConfiguration($service_name, $service_config_file);
    }

    /**
     * Shortcut for adding a tag to a loaded service
     * @param $service_name
     * @param $tag_name
     * @return bool
     */
    public function addTagToService($service_name, $tag_name)
    {
        if(!isset($this->services_config[$service_name]))
            $this->loadServiceConfiguration($service_name);

        if(!isset($this->services_config[$service_name]['service']['tags']))
            $this->services_config[$service_name]['service']['tags'] = [];
        if(!in_array($tag_name, $this->services_config[$service_name]['service']['tags'])){
            $this->services_config[$service_name]['service']['tags'][] = $tag_name;
            return true;
        }
        return false;
    }

    /**
     * Shortcut for removing a tag from a loaded service
     * @param $service_name
     * @param $tag_name
     * @return bool
     */
    public function removeTagFromService($service_name, $tag_name){
        if(!isset($this->services_config[$service_name]))
            $this->loadServiceConfiguration($service_name);

        if(isset($this->services_config[$service_name]['service']['tags'])){
            $key = array_search($tag_name, $this->services_config[$service_name]['service']['tags']);
            if($key !== false){
                $this->services_config['service']['tags'] = array_splice($this->services_config[$service_name]['service']['tags'], $key, 1);
                return true;
            }
        }
        return false;
    }

    /**
     * Get the configuration of a specific service from the current loaded services
     * @param $service_name
     * @return null
     */
    public function getServiceConfiguration($service_name)
    {
        return @$this->services_config[$service_name] ?: null;
    }

    /**
     * Get current consul leader
     * @return bool
     */
    public function getLeader()
    {
        return Http::getJson($this->base_url . '/status/leader');
    }

    /**
     * Get current consul peers
     * @return bool
     */
    public function getPeers()
    {
        return Http::getJson($this->base_url . '/status/peers');
    }

    /**
     * Get registered instances of a given service
     * @param string $service_name
     * @param string $service_tag
     * @return array
     */
    public function getService($service_name, $service_tag = '')
    {
        if(!empty($service_tag))
            $service_name .= '?tag='.$service_tag;
        return Http::getJson($this->base_url . '/catalog/service/' . $service_name);
    }

    /**
     * Get every register service
     * @return array
     */
    public function getServices()
    {
        return Http::getJson($this->base_url . '/catalog/services');
    }

    /**
     * Get a consul node
     * @param $node_name
     * @return array
     */
    public function getNode($node_name){
        return Http::getJson($this->base_url . '/catalog/node/' . $node_name);
    }

    /**
     * Get the current running consul node
     * @return array
     */
    public function getCurrentNode()
    {
        $node_name = gethostname();
        return $this->getNode($node_name);
    }

    /**
     * Add an external service to the current cluster
     * @param $service
     * @return bool|mixed
     */
    public function addExternalService($service)
    {
        return Http::put($this->base_url . '/catalog/register', json_encode($service));
    }

    /**
     * Add a server to the join
     * @param $server_ip
     * @return bool
     */
    public function addServerToJoinList($server_ip)
    {
        if(is_null($this->config))
            return false;

        $this->config['retry_join'] = @$this->config['retry_join'] ?: [];
        if(!in_array($server_ip, $this->config['retry_join'])){
            $this->config['retry_join'][] = $server_ip;
            return true;
        }
        return false;
    }

    /**
     * Add a list of servers ip to the join list
     * @param $servers_ip
     * @param array $ignore_list
     * @return bool
     */
    public function addServerListToJoinList($servers_ip, $ignore_list = array())
    {
        $updated = false;
        foreach($servers_ip as $ip)
            if(!in_array($ip, $ignore_list))
                $updated = $this->addServerToJoinList($ip) ?: $updated;
        return $updated;
    }

    /**
     * Get the session info of an active session
     * @param $session_id
     * @return array
     */
    public function getSessionInfo($session_id){
        return Http::getJson($this->base_url . '/session/info/' . $session_id);
    }

    /**
     * Creates a new session
     * @param array $session_data
     * @return string
     */
    public function createSession($session_data = array())
    {
        $result = Http::put($this->base_url . '/session/create', $session_data);
        $result = @json_decode($result, true) ?: array('ID' => null);
        return $result['ID'];
    }

    /**
     * Destroy a current active session
     * @param $session_id
     * @return bool
     */
    public function destroySession($session_id)
    {
        Http::put($this->base_url . '/session/destroy/' . $session_id, null, $http_code);
        return $http_code == 200;
    }

    /**
     * Get a new lock
     * @param $lock_name
     * @param $session_id
     * @param array $body
     * @return bool
     */
    public function getLock($lock_name, $session_id, $body = array())
    {
        $lock = Http::put($this->base_url . '/kv/' . $lock_name . '?acquire=' . $session_id, $body, $http_code);
        return $lock == 'true';
    }

    /**
     * Releases a lock
     * @param $lock_name
     * @param $session_id
     * @return bool
     */
    public function releaseLock($lock_name, $session_id)
    {
        $lock = Http::put($this->base_url . '/kv/' . $lock_name . '?release=' . $session_id, null, $http_code);
        return $lock == 'true';
    }
}