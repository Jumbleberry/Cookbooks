<?php

class JbRedis
{

    private $ip;
    private $port;
    private $config_dir;
    private $config;
    private $sentinel_name;
    private $sentinel_config;
    private $sentinel_quorum;

    function __construct($ip = '127.0.0.1', $port = 6379, $config_dir = '/etc/redis', $sentinel_name = '', $sentinel_quorum = 1)
    {
        $this->ip = $ip;
        $this->port = $port;
        $this->config_dir = $config_dir;
        $this->sentinel_name = $sentinel_name;
        $this->sentinel_quorum = $sentinel_quorum;
    }

    public function loadConfiguration($config_file = null)
    {
        $config_file = $config_file ?: $this->port . '.conf';
        $this->config = file_get_contents($this->config_dir . '/' . $config_file);
    }

    public function getConfiguration()
    {
        return $this->config;
    }

    public function saveConfiguration($config = null, $config_file = null)
    {
        $config_file = $config_file ?: $this->port . '.conf';
        $config = $config ?: $this->config;
        $saved = file_put_contents($this->config_dir . '/' . $config_file, trim($config)) != false;
        $this->loadConfiguration($config_file);
        return $saved;
    }

    public function setMaster($master_ip, $master_port)
    {
        if (!$this->config)
            $this->loadConfiguration();
        //Remove any other master currently in the configuration
        $this->config = preg_replace("/^slaveof.*/m", null, $this->config);
        $this->config .= PHP_EOL . "slaveof " . $master_ip . " " . $master_port;
    }

    public function startService($service_suffix = null)
    {
        $service_suffix = $service_suffix ?: $this->port;
        exec('sudo service redis' . $service_suffix . ' stop');
        exec('sudo service redis' . $service_suffix . ' start');
    }

    public function getSentinelConfiguration()
    {
        return $this->sentinel_config;
    }

    public function loadSentinelConfiguration($config_file = null)
    {
        $config_file = $config_file ?: 'sentinel_' . $this->sentinel_name . '.conf';
        $this->sentinel_config = file_get_contents($this->config_dir . '/' . $config_file);
    }

    public function setSentinelMonitor($master_ip, $master_port)
    {
        if (!$this->sentinel_config)
            $this->loadSentinelConfiguration();
        //Remove any other monitoring master
        $this->sentinel_config = preg_replace("/^sentinel.monitor.*/m", null, $this->sentinel_config);
        $this->sentinel_config = 'sentinel monitor sentinel_' . $this->sentinel_name . ' ' . $master_ip . ' ' . $master_port . ' ' . $this->sentinel_quorum . PHP_EOL . $this->sentinel_config;
    }

    public function saveSentinelConfiguration($config = null, $config_file = null)
    {
        $config_file = $config_file ?: 'sentinel_' . $this->sentinel_name . '.conf';
        $config = $config ?: $this->sentinel_config;
        $saved = file_put_contents($this->config_dir . '/' . $config_file, trim($config)) != false;
        $this->loadSentinelConfiguration($config_file);
        return $saved;
    }
}