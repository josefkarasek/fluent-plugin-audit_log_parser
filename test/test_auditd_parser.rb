require 'fluent/test'
require 'fluent/parser'
require 'json'
require_relative '../lib/fluent/plugin/auditd'


module ParserTest
  include Fluent
  
  class AuditdParserTest < ::Test::Unit::TestCase

    def setup()
      @parser = Fluent::Auditd.new()
    end
    
    data("line" => [
'{
  "type": "VIRT_CONTROL",
  "msg": {
    "auid": "1000",
    "reason": "api",
    "op": "_ping",
    "user": "jkarasek",
    "exe": "\"/usr/bin/dockerd-current\"",
    "res": "success"
  },
  "pid": "1115",
  "uid": "0",
  "auid": "4294967295",
  "ses": "4294967295",
  "subj": "system_u:system_r:container_runtime_t:s0"
}', "type=VIRT_CONTROL msg=audit(1505977228.725:3309): pid=1115 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:container_runtime_t:s0 msg='auid=1000 exe=? reason=api op=_ping vm=? vm-pid=? user=jkarasek hostname=?  exe=\"/usr/bin/dockerd-current\" hostname=? addr=? terminal=? res=success'"])
    def test_correct_data(data)
      begin
        expected, target = data
        target_json = JSON.pretty_generate (@parser.parse_auditd_line target)
        assert_equal(expected, target_json)
      rescue Fluent::Auditd::AuditdParserException => e
        fail(e.message)
      end
    end

    data("line" => ["expecting AuditdParserException", "type=VIRT_CONTROL msg=audit(1505977228.725:3309): pid=1115 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:container_runtime_t:s0 msg='auid=1000 exe=? reason=api op=_ping vm=? vm-pid=? user=jkarasek hostname=?  exe=\"/usr/bin/dockerd-current\" hostname=? addr=? terminal=? res=success"])
    def test_missing_apostrophe(data)
      expected, target = data
      assert_raise Fluent::Auditd::AuditdParserException do 
        JSON.pretty_generate (@parser.parse_auditd_line target)
      end
    end

    private

    def fail(reason)
      assert(false, reason)
    end

  end
end