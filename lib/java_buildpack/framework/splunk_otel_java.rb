# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2020 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'

module JavaBuildpack
  module Framework

    # Main class for adding the Splunk OpenTelemetry instrumentation agent
    class SplunkOtelJava < JavaBuildpack::Component::VersionedDependencyComponent

      def initialize(context)
        super(context)
      end

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_jar
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        java_opts = @droplet.java_opts
        java_opts.add_javaagent(@droplet.sandbox + jar_name)

        # token = @application.environment['SPLUNK_ACCESS_TOKEN']
        # java_opts.add_system_property('splunk.access.token', token)
        app_name = @application.details['application_name']
        java_opts.add_system_property('otel.service.name', app_name)
      end

      protected
      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        # api_key_defined = @application.environment.key?('SPLUNK_ACCESS_TOKEN') && !@application.environment['SPLUNK_ACCESS_TOKEN'].empty?
        has_user_service = @application.services.one_service? REQUIRED_SERVICE_NAME_FILTER, 
        has_user_service
      end

      private
      REQUIRED_SERVICE_NAME_FILTER = /splunk-o11y/.freeze

    end
  end
end
