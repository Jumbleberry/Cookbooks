#!/usr/bin/php
<?php
require dirname(__FILE__) . '/GearmanAdmin/GearmanAdmin.php';
$code = 2;

// Check if we can connect to service
try {
    $admin  = new GearmanAdmin(@$argv[1] ?: null);
    $code   = 0;
    
    // There's no functions registered but we connected - something is wrong but not fatal
    if (!count($admin->getStatus()->getFunctions()))
        $code = 1;
    
    // No workers but everything else is fine - something is wrong but again, not fatal
    if (!count($admin->getWorkers()))
        $code = 1;
    
// Failed to connect, service is down
} catch (Exception $e) {
    $code = 2;
}

exit($code);