<?php

define('REDIS_IP', '127.0.0.1');
define('REDIS_PORT', 6379);
define('REDIS_CONFIG_DIR', '/etc/redis');
define('REDIS_MASTER_IP', '127.0.0.1');
define('REDIS_MASTER_PORT', 6380);
define('SENTINEL_NAME', 'jbcluster');
define('SENTINEL_QUORUM', 3);
define('SENTINEL_PORT', 26379);

/**
 * Class JbRedisTest
 */
class JbRedisTest extends PHPUnit_Framework_TestCase {
    /**
     * @var JbRedis
     */
    private $redis;

    /**
     * Test initial setup
     */
    protected function setUp()
    {
        $this->redis = new JbRedis(REDIS_IP, REDIS_PORT, REDIS_CONFIG_DIR, SENTINEL_NAME);
        parent::setUp();
    }

    /**
     * Test for loading and getting a loaded redis configuration
     */
    public function testLoadAndGetConfiguration()
    {
        $redis_config = $this->redis->getConfiguration();
        $this->assertNull($redis_config);
        $this->redis->loadConfiguration();
        $redis_config = $this->redis->getConfiguration();
        $this->assertContains('port '.REDIS_PORT, $redis_config);
    }

    /**
     * Test for saving a loaded configuration into a config file
     */
    public function testSaveConfiguration()
    {
        $this->redis->loadConfiguration();
        $redis_config = $this->redis->getConfiguration();
        $redis_config .= "\n#TEST_SAVE_CONFIGURATION";
        $this->redis->saveConfiguration($redis_config);
        $redis_config = $this->redis->getConfiguration();
        $this->assertContains("#TEST_SAVE_CONFIGURATION", $redis_config);
        $redis_config = preg_replace("/^#TEST_SAVE_CONFIGURATION.*/m", null, $redis_config);
        $this->redis->saveConfiguration($redis_config);
    }

    /**
     * Test for setting a master on the loaded configuration
     */
    public function testSetMasterServer()
    {
        $this->redis->loadConfiguration();
        $this->redis->setMaster(REDIS_MASTER_IP, REDIS_MASTER_PORT);
        $redis_config = $this->redis->getConfiguration();
        $this->assertContains("slaveof " . REDIS_MASTER_IP . " " . REDIS_MASTER_PORT, $redis_config);
    }

    /**
     * Test for loading and getting the sentinel configuration
     */
    public function testLoadAndGetSentinelConfiguration(){
        $sentinel_config = $this->redis->getSentinelConfiguration();
        $this->assertNull($sentinel_config);
        $this->redis->loadSentinelConfiguration();
        $sentinel_config = $this->redis->getSentinelConfiguration();
        $this->assertContains('port '.SENTINEL_PORT, $sentinel_config);
    }

    /**
     * Test for setting a redis master on the loaded sentinel configuration
     */
    public function testSetSentinelMonitor(){
        $this->redis->loadSentinelConfiguration();
        $this->redis->setSentinelMonitor(REDIS_MASTER_IP, REDIS_MASTER_PORT);
        $sentinel_config = $this->redis->getSentinelConfiguration();
        $this->assertContains("sentinel monitor sentinel_" . SENTINEL_NAME . " " . REDIS_MASTER_IP . " " . REDIS_MASTER_PORT, $sentinel_config);
    }

    /**
     * Test for saving the sentinel configuration into a config file
     */
    public function testSaveSentinelConfiguration(){
        $this->redis->loadSentinelConfiguration();
        $sentinel_config = $this->redis->getSentinelConfiguration();
        $sentinel_config .= "\n#TEST_SAVE_CONFIGURATION";
        $this->redis->saveSentinelConfiguration($sentinel_config);
        $sentinel_config = $this->redis->getSentinelConfiguration();
        $this->assertContains("#TEST_SAVE_CONFIGURATION", $sentinel_config);
        $sentinel_config = preg_replace("/^#TEST_SAVE_CONFIGURATION.*/m", null, $sentinel_config);
        $this->redis->saveSentinelConfiguration($sentinel_config);
    }
}