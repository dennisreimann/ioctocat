guard 'shell' do
  watch(%r{(.+\.(h|m|xib)).*}) do |m|
    puts "\n#{m[0]} changed, running unit tests"
    result = `TestScripts/run_tests_from_cli.rb`
    if $? == 0
      Notifier.notify("yay :)", :title => "Tests successful", :image => :success)
      puts "Unit Tests successful"
    else
      Notifier.notify(result.scan(/\[.*\]/).to_a.join("\n"), :title => "Tests failed", :image => :failed)
      puts result
    end
  end
end
