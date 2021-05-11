Configuration ParisTZ {

Import-DscResource -ModuleName "xTimeZone" -ModuleVersion "1.6.0.0"

Node TimeZoneConfig {

xTimeZone Paris {
IsSingleInstance = 'Yes'
TimeZone = 'Central European Standard Time'
}
}
}

ParisTZ

new-dscchecksum -path ./ParisTZ/TimeZoneConfig.mof