<?php

/**
 * Class AwsTest
 */
class AwsTest extends PHPUnit_Framework_TestCase {
    static $onAws;

    /**
     * @var Aws
     */
    protected $aws;

    /**
     * @var string
     */
    protected $environment;

    public static function setUpBeforeClass()
    {
        self::$onAws = @file_get_contents('http://instance-data.ec2.internal') ? true: false;
    }

    /**
     * Test setup
     */
    protected function setUp()
    {
        $this->environment = self::$onAws ? 'staging' : 'testing';
        $this->aws = new Aws($this->environment);
    }

    /**
     * Test to get a group of instances using the aws cli
     */
    public function testGetInstancesByTag(){
        $result = $this->aws->getInstancesByTag('environment', $this->environment);
        $this->assertNotEmpty($result);
        $this->assertArrayHasKey('Instances', $result[0]);
        $this->assertNotEmpty($result[0]['Instances']);
        $this->assertContains(array('Value' => $this->environment, 'Key' => 'environment'), $result[0]['Instances'][0]['Tags']);
        return $result;
    }

    /**
     * Test for updating the tag of an instance using the InstanceId
     * @depends testGetInstancesByTag
     * @param array $reservations
     */
    public function testUpdateInstanceTag($reservations = null){
        $instance_id = $reservations[0]['Instances'][0]['InstanceId'];
        if( !in_array($this->environment, array('testing', 'development')) ) {
            $tag_name = 'Test:tag';
            $tag_value = uniqid();
            $instances = $this->aws->getInstancesByTag($tag_name, $tag_value);
            $this->assertEmpty($instances);
            $result = $this->aws->updateInstanceTag($instance_id, $tag_name, $tag_value);
            $this->assertTrue($result);
            $instances = $this->aws->getInstancesByTag($tag_name, $tag_value);
            $this->assertNotEmpty($instances);
            $this->assertContains(array('Value' => $tag_value, 'Key' => $tag_name), $instances[0]['Instances'][0]['Tags']);
        }
    }

    /**
     * Test for getting the current instance from aws
     */
    public function testGetCurrentInstance(){
        $current_instance = $this->aws->getCurrentInstance();
        $this->assertNotEmpty($current_instance);
        $this->assertContains(array('Value' => gethostname(), 'Key' => 'opsworks:instance'), $current_instance['Tags']);
        return $current_instance;
    }

    /**
     * Test for getting a tag from tags array on an instance
     * @depends testGetCurrentInstance
     * @param $current_instance
     */
    public function testGetTag($current_instance){
        $tag = $this->aws->getTag('opsworks:instance', $current_instance['Tags']);
        $this->assertEquals(gethostname(), $tag);
    }

    /**
     * Test for getting a list of ip from an instance group
     * @depends testGetInstancesByTag
     * @param null $reservations
     */
    public function testGetIpFromInstances($reservations = null){
        $ips = $this->aws->getIpFromInstances($reservations);
        $this->assertContains($reservations[0]['Instances'][0]['PrivateIpAddress'], $ips);
    }

}