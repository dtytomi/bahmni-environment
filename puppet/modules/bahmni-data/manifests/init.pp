class bahmni-data {
	$bahmni_data_temp = "${temp_dir}/bahmni-data"

  file { "${bahmni_data_temp}" :
    ensure    => directory,
    recurse   => true,
    force     => true,
    purge     => true,
		mode 	    => 666,
    owner     => "${bahmni_user}"
	}

	file { "${bahmni_data_temp}/bahmni-flyway-ant.xml" :
    path    => "${bahmni_data_temp}/bahmni-flyway-ant.xml",
    content     => template("bahmni-data/bahmni-flyway-ant.erb"),
	  ensure      => present,
	  owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
	  mode        => 554,
	  require			=> File["${bahmni_data_temp}"]
	}

  file { "${bahmni_data_temp}/bahmni-data-migration.sh" :
    path    => "${bahmni_data_temp}/bahmni-data-migration.sh",
    ensure      => present,
    content     => template("bahmni-data/bahmni-data-migration.erb"),
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 554,
    require     => File["${bahmni_data_temp}"]
  }

  file { "${bahmni_data_temp}/lib" :
    ensure => directory,
    mode  => 666
  }

  file { "${bahmni_data_temp}/flyway.properties" :
    path        => "${bahmni_data_temp}/flyway.properties",
    ensure      => present,
    content     => template("bahmni-data/flyway.properties.erb"),
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 554,
    require     => File["${bahmni_data_temp}"]
  }

  file { "${bahmni_data_temp}/logging.properties" :
    path        => "${bahmni_data_temp}/logging.properties",
    ensure      => present,
    content     => template("bahmni-data/logging.properties"),
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    mode        => 554,
    require     => File["${bahmni_data_temp}"]
  }
  
  exec { "bahmni db upgrade" :
  	command		=> "sh bahmni-data-migration.sh flyway.properties ${build_output_dir}/openmrs-data-jars.zip ${ant_home} ${build_output_dir}/${openmrs_distro_file_name_prefix} ${openmrs_modules_dir} ${deployment_log_expression}",
  	require 	=> [File["${bahmni_data_temp}/bahmni-flyway-ant.xml"], File["${bahmni_data_temp}/bahmni-data-migration.sh"], File["${bahmni_data_temp}/flyway.properties"], File["${bahmni_data_temp}/logging.properties"]],
  	path 			=> "${os_path}",
  	cwd				=> "${bahmni_data_temp}"
  }
}