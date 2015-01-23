<?php
define('CONSUL_BIN', '/usr/local/bin/consul');
define('CONSUL_BASE_URL', 'http://localhost:8500/v1');
define('CONSUL_CONFIG_DIR', '/etc/consul.d');
define('CONSUL_TEST_SERVICE_CONFIG_FILE', 'redis6379.json');
define('CONSUL_TEST_SERVICE_NAME', 'redis');
define('CONSUL_TEST_IP', '192.168.50.10');

/**
 * Class JbConsulTest
 */
class ConsulTest extends PHPUnit_Framework_TestCase
{
    /**
     * @var Consul
     */
    protected $consul;

    /**
     * Test setup
     */
    protected function setUp()
    {
        $this->consul = new Consul(CONSUL_BASE_URL, CONSUL_CONFIG_DIR, CONSUL_BIN);
        parent::setUp();
    }

    /**
     * Test if the agent is running
     */
    public function testAgentRunning()
    {
        $status = $this->consul->agentRunning();
        $this->assertTrue($status, "Can't get info from the agent, no agent running!");
    }

    /**
     * Test the reload agent function
     * @depends testAgentRunning
     */
    public function testReloadAgent()
    {
        $status = $this->consul->reloadAgent();
        $this->assertTrue($status, "Can't reload the agent, no agent running!");
    }

    /**
     * Test for joining a different consul server
     * @depends testAgentRunning
     */
    public function testJoinServer()
    {
        $server_ip = CONSUL_TEST_IP;
        $status = $this->consul->joinServer($server_ip);
        $this->assertTrue($status, 'Cant join the server ' . $server_ip);
        $this->consul->loadConfiguration();
        $status = $this->consul->joinServer($server_ip, true);
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('retry_join', $consul_config);
        $this->assertContains($server_ip, $consul_config['retry_join']);
    }

    /**
     * Test for joining multiple servers
     */
    public function testJoinMultipleServers()
    {
        $servers_ip = array(CONSUL_TEST_IP, CONSUL_TEST_IP, CONSUL_TEST_IP);
        $status = $this->consul->joinMultipleServers($servers_ip);
        $this->assertTrue($status, 'Cant join multiple servers');
        $this->consul->loadConfiguration();
        $status = $this->consul->joinMultipleServers($servers_ip, true);
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('retry_join', $consul_config);
        $this->assertContains($servers_ip[0], $consul_config['retry_join']);
    }

    /**
     * Test for getting the current leader from consul
     * @depends testAgentRunning
     */
    public function testGetLeader()
    {
        $status = $this->consul->getLeader();
        $this->assertNotEmpty($status, "Can't connect to consul api or no leader elected");
    }

    /**
     * Test for getting the current peers on the cluster
     * @depends testAgentRunning
     */
    public function testGetPeers()
    {
        $status = $this->consul->getPeers();
        $this->assertNotEmpty($status, "Can't connect to consul api or no peers connected to the cluster");
    }

    /**
     * Test for getting all the services currently registered on the cluster
     * @depends testAgentRunning
     */
    public function testGetServices()
    {
        $services = $this->consul->getServices();
        $this->assertNotEmpty($services, "Can't connect to consul api");
        //It should at least have the consul service registered
        $this->assertArrayHasKey('consul', $services);
    }

    /**
     * Test for getting a specific service from the cluster
     * @depends testAgentRunning
     */
    public function testGetService()
    {
        $service_name = CONSUL_TEST_SERVICE_NAME;

        $service = $this->consul->getService($service_name);
        $this->assertNotEmpty($service, "Can't connect to consul api or No service registered with that name");
        $this->assertArrayHasKey('ServiceName', $service[0]);
    }

    /**
     * Test for getting a specific node from the cluster
     * @depends testAgentRunning
     */
    public function testGetNode()
    {
        $node_name = gethostname();
        $node = $this->consul->getNode($node_name);
        $this->assertArrayHasKey('Node', $node, "Can't find node with name: " . $node_name);
        $this->assertContains($node_name, $node['Node']);
    }

    /**
     * Test to get the current node from the cluster
     * @depends testAgentRunning
     */
    public function testGetCurrentNode()
    {
        $node = $this->consul->getCurrentNode();
        $this->assertArrayHasKey('Node', $node);
        $this->assertContains(gethostname(), $node['Node']);
    }

    /**
     * Test to get a specific service with a tag
     * @depends testAgentRunning
     */
    public function testGetServiceWithTag()
    {
        $service_name = CONSUL_TEST_SERVICE_NAME;
        $tag_name = 'master';
        $service = $this->consul->getService($service_name, $tag_name);
        $this->assertNotEmpty($service, "Can't connect to consul api or No service registered with that name and tag");
        $this->assertArrayHasKey('ServiceTags', $service[0]);
        $this->assertNotEmpty($service[0]['ServiceTags']);
        $this->assertContains($tag_name, $service[0]['ServiceTags']);
    }

    /**
     * Test to add an external service to the cluster
     * @depends testAgentRunning
     */
    public function testAddExternalService()
    {
        $service_mock = [
            "Node" => 'test_node',
            "Address" => 'service.test.test',
            "Service" => [
                "Service" => 'test_service',
                "Port" => intval('9696'),
                "Tags" => ['test', 'slave']
            ]
        ];

        $service_added = $this->consul->addExternalService($service_mock);
        $this->assertEquals($service_added, 'true');

        $service = $this->consul->getService($service_mock['Service']['Service'], $service_mock['Service']['Tags'][0]);
        $this->assertNotEmpty($service, "Can't connect to consul api or No service registered with that name and tag");
        $this->assertArrayHasKey('ServiceTags', $service[0]);
        $this->assertNotEmpty($service[0]['ServiceTags']);
        $this->assertContains($service_mock['Service']['Tags'][0], $service[0]['ServiceTags']);
    }

    /**
     * Test for loading the consul configuration from file
     * @depends testAgentRunning
     */
    public function testLoadConfiguration()
    {
        $consul_config = $this->consul->getConfiguration();
        $this->assertNull($consul_config);
        $this->consul->loadConfiguration();
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('data_dir', $consul_config);
    }

    /**
     * Test to save the current configuration on a config file
     * @depends testAgentRunning
     */
    public function testUpdateConfiguration()
    {
        $this->consul->loadConfiguration();
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('server', $consul_config);
        $this->assertTrue($consul_config['server']);
        $consul_config['server'] = false;
        $this->consul->saveConfiguration($consul_config);
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('server', $consul_config);
        $this->assertFalse($consul_config['server']);
        $consul_config['server'] = true;
        $this->consul->saveConfiguration($consul_config);
    }

    /**
     * Test to add a server to the current join list
     * @depends testAgentRunning
     */
    public function testAddServerToJoinList()
    {
        $server_ip = CONSUL_TEST_IP;
        $this->consul->loadConfiguration();
        $this->consul->addServerToJoinList($server_ip);
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('retry_join', $consul_config);
        $this->assertContains($server_ip, $consul_config['retry_join']);
    }

    /**
     * Test to add multiple server to the join list
     */
    public function testAddServerListToJoinList()
    {
        $servers_ip = array('192.168.10.60', '192.168.10.61', '192.168.10.62', '192.168.10.63');
        $ignore_list = array('192.168.10.60');
        $this->consul->loadConfiguration();
        $this->consul->addServerListToJoinList($servers_ip, $ignore_list);
        $consul_config = $this->consul->getConfiguration();
        $this->assertArrayHasKey('retry_join', $consul_config);
        $this->assertContains($servers_ip[1], $consul_config['retry_join']);
        $this->assertContains($servers_ip[2], $consul_config['retry_join']);
        $this->assertContains($servers_ip[3], $consul_config['retry_join']);
        $this->assertNotContains($servers_ip[0], $consul_config['retry_join']);
    }

    /**
     * Test to check if the add server to join list only return true when there was a change in the configuration
     */
    public function testAddRepeatedServerToJoinList()
    {
        $servers_ip = array('192.168.10.60', '192.168.10.61', '192.168.10.62', '192.168.10.63');
        $this->consul->loadConfiguration();
        $updated = $this->consul->addServerListToJoinList($servers_ip);
        $this->assertTrue($updated);
        $repeated_servers_ip = array('192.168.10.61', '192.168.10.63');
        $updated_repeated = $this->consul->addServerListToJoinList($repeated_servers_ip);
        $this->assertFalse($updated_repeated);
    }

    /**
     * Test to load a service configuration from file
     * @depends testAgentRunning
     */
    public function testLoadServiceConfiguration()
    {
        $service_name = CONSUL_TEST_SERVICE_NAME;
        $service_config_file = CONSUL_TEST_SERVICE_CONFIG_FILE;
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $this->assertNull($service_config);
        $this->consul->loadServiceConfiguration($service_name, $service_config_file);
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $this->assertArrayHasKey('service', $service_config);
        $this->assertContains(CONSUL_TEST_SERVICE_NAME, $service_config['service']);
    }

    /**
     * Test to save a service configuration to a config file
     * @depends testLoadServiceConfiguration
     */
    public function testSaveServiceConfiguration()
    {
        $service_name = CONSUL_TEST_SERVICE_NAME;
        $service_config_file = CONSUL_TEST_SERVICE_CONFIG_FILE;
        $this->consul->loadServiceConfiguration($service_name, $service_config_file);
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $new_port = rand(3000, 6000);
        $service_config['service']['port'] = $new_port;
        $this->consul->saveServiceConfiguration($service_name, $service_config_file, $service_config);
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $this->assertArrayHasKey('service', $service_config);
        $this->assertEquals($new_port, $service_config['service']['port']);
    }

    /**
     * Add a tag to a loaded service configuration
     * @depends testSaveServiceConfiguration
     */
    public function testAddAndRemoveTagFromService()
    {
        $service_name = CONSUL_TEST_SERVICE_NAME;
        $service_config_file = CONSUL_TEST_SERVICE_CONFIG_FILE;
        $tag_name = 'test';
        $this->consul->loadServiceConfiguration($service_name, $service_config_file);
        $updated = $this->consul->addTagToService($service_name, $tag_name);
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $this->assertTrue($updated);
        $this->assertArrayHasKey('tags', $service_config['service']);
        $this->assertContains($tag_name, $service_config['service']['tags']);
        $this->consul->removeTagFromService($service_name, $tag_name);
        $service_config = $this->consul->getServiceConfiguration($service_name);
        $this->assertNotContains($tag_name, $service_config['service']['tags']);
    }

    /**
     * Test for creating and destroy sessions on consul
     * @depends testAgentRunning
     */
    public function testCreateAndDestroySession()
    {
        $session_id = $this->consul->createSession();
        $this->assertNotEmpty($session_id);
        $session_info = $this->consul->getSessionInfo($session_id);
        $this->assertArrayHasKey('ID', $session_info[0]);
        $this->assertEquals($session_info[0]['ID'], $session_id);
        $status = $this->consul->destroySession($session_id);
        $this->assertTrue($status);
        $session_info = $this->consul->getSessionInfo($session_id);
        $this->assertEmpty($session_info);
    }

    /**
     * Test for creating and releasing a lock
     * @depends testCreateAndDestroySession
     */
    public function testGetAndReleaseALock()
    {
        $lock_name = 'testing/lock';
        $session_id = $this->consul->createSession();
        $lock_acquire = $this->consul->getLock($lock_name, $session_id, ['testing' => 'lock']);
        $this->assertTrue($lock_acquire);
        $lock_released = $this->consul->releaseLock($lock_name, $session_id);
        $this->assertTrue($lock_released);
        $this->consul->destroySession($session_id);
    }
}
