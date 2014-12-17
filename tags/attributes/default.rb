default['aws']['tags']['force_remove'] = [
    "production"    => "true",
    "redis-write"   => "true",
    "redis-read"    => "true",
    "gearman"       => "true",
    "jbx-core"      => "true",
    "jbx-mesh"      => "true",
    "jb-admin"      => "true"
]

default['aws']['tags']['add'] = []