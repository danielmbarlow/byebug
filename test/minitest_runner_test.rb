# frozen_string_literal: true

require "test_helper"

module Byebug
  class MinitestRunnerTest < Minitest::Test
    def test_runs
      output = run_minitest_runner("test/debugger_alias_test.rb")

      assert_includes output, "\n.\n"
    end

    def test_per_test_class
      output = run_minitest_runner("DebuggerAliasTest")

      assert_includes output, "\n.\n"
    end

    def test_per_test
      output = run_minitest_runner("test_aliases_debugger_to_byebug")

      assert_includes output, "\n.\n"
    end

    def test_combinations
      output = run_minitest_runner(
        "DebuggerAliasTest",
        "test_script_processor_clears_history"
      )

      assert_includes output, "\n..\n"
    end

    def test_with_verbose_option
      output = run_minitest_runner("DebuggerAliasTest", "--verbose")

      assert_includes \
        output,
        "Byebug::DebuggerAliasTest#test_aliases_debugger_to_byebug = 0.00 s = ."

      assert_includes \
        output,
        "Run options: --name=/DebuggerAliasTest/ --verbose"
    end

    def test_with_seed_option
      output = run_minitest_runner("DebuggerAliasTest", "--seed=37")

      assert_includes output, "\n.\n"

      assert_includes \
        output,
        "Run options: --name=/DebuggerAliasTest/ --seed=37"
    end

    private

    def run_minitest_runner(*args)
      test_name = Thread.current.backtrace_locations[2].label

      out, = capture_subprocess_io do
        assert_equal true, system(
          { "RUBYOPT" => "-rsimplecov", "MINITEST_TEST" => test_name },
          *binstub,
          *args
        )
      end

      out
    end

    def binstub
      cmd = "bin/minitest"
      return [cmd] unless windows?

      %W[#{RbConfig.ruby} #{cmd}]
    end
  end
end
