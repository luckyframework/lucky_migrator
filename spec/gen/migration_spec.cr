require "../spec_helper"

include CleanupHelper

describe Gen::Migration do
  it "generates a migration with custom name" do
    with_cleanup do
      ARGV.push("Should Ignore This Name")

      Gen::Migration.new.call("Custom")

      should_generate_migration named: "custom.cr"
    end
  end
end

private def should_generate_migration(named name : String)
  Dir.new("./db/migrations").any?(&.ends_with?(name)).should be_true
end
