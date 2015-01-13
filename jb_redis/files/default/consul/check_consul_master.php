<?php
define('CURRENT_IP', $argv[1]);
define('CURRENT_PORT', $argv[2]);
define('CONSUL_BASE_URL', 'http://localhost:<%= node['consul']['ports']['http'] || 8500 %>');

//Get the current redis information
$current_server = CURRENT_IP . ':' . CURRENT_PORT;
$sentinel_redis_master = getSentinelRedisMaster();

$result = 0;
//Check if the current redis master on sentinel is the same service that we are currently checking
if($sentinel_redis_master == $current_server)
    //Check if consul has the right service registered
    $result = (getConsulRedisMaster() != $sentinel_redis_master) ? 1 : 0;
echo $result;

/**
 * Get the current redis master from redis sentinel
 * @return string
 */
function getSentinelRedisMaster()
{
    exec("redis-cli info | grep 'master_host\\|master_port'", $redis_info);
    $result = array();
    foreach ($redis_info as $option) {
        $kv = explode(':', $option);
        $result[$kv[0]] = $kv[1];
    }
    return $result['master_host'] . ':' . $result['master_port'];
}

/**
 * Get the current redis master from consul
 * @return string
 */
function getConsulRedisMaster()
{
    $master = null;
    $result = json_decode(getCurlRequest(CONSUL_BASE_URL . '/v1/catalog/service/redis?tag=master'), true);
    if(count($result))
        $master = $result[0]['Address'] . ':' . $result[0]['ServicePort'];
    return $master;
}

/**
 * Execute a curl get request to the given url
 * @param  string url
 * @return string
 */
function getCurlRequest($url)
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPGET,true);
    return curl_exec($ch);
}