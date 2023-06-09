# GitLab License Generator

LICENSE_TARGET_PRIVATE_KEY = "license_key"
LICENSE_TARGET_PUBLIC_KEY = "license_key.pub"
TARGET_LICENSE_FILE = 'result.gitlab-license'

puts "[*] Booting generator"

require 'openssl'

require_relative 'lib/license.rb'
CORE_LIB_VERSION = '2.2.1'

puts "[i] Using core library version #{CORE_LIB_VERSION}"

if !File.exist?(LICENSE_TARGET_PRIVATE_KEY) || !File.exist?(LICENSE_TARGET_PUBLIC_KEY)
  puts "[*] Generating RSA keys..."
  key = OpenSSL::PKey::RSA.new(2048)
  File.write(LICENSE_TARGET_PRIVATE_KEY, key.to_pem)
  File.write(LICENSE_TARGET_PUBLIC_KEY, key.public_key.to_pem)
end

puts "[*] Loading RSA keys..."

public_key = OpenSSL::PKey::RSA.new File.read(LICENSE_TARGET_PUBLIC_KEY)
private_key = OpenSSL::PKey::RSA.new File.read(LICENSE_TARGET_PRIVATE_KEY)

puts "[*] Building license..."

Gitlab::License.encryption_key = private_key

license = Gitlab::License.new

# don't use gitlab inc, search `gl_team_license` in lib for details
license.licensee = {
  "Name"    => "Black Man",
  "Company" => "Automacom, Inc.",
  "Email"   => "noname@mail.com"
}

# required of course
license.starts_at         = Date.new(1976, 4, 1)

# required since gem gitlab-license v2.2.1
license.expires_at        = Date.new(2500, 4, 1)

# prevent gitlab crash at
# notification_start_date = trial? ? expires_at - NOTIFICATION_DAYS_BEFORE_TRIAL_EXPIRY : block_changes_at
license.block_changes_at  = Date.new(2500, 4, 1)

# required
license.restrictions      = {
  plan: 'premium',
  # STARTER_PLAN = 'starter'
  # PREMIUM_PLAN = 'premium'
  # ULTIMATE_PLAN = 'ultimate'

  active_user_count: 1000,
  # required, just dont overflow
}

puts "[*] Calling export..."

puts ""
puts "====================================================="

puts JSON.pretty_generate(JSON.parse(license.to_json))

puts "====================================================="

data = license.export
File.open(TARGET_LICENSE_FILE, "w") { |f| f.write(data) }

puts "====================================================="
puts ""

puts "[*] License generated successfully!"
puts "[*] License file: #{TARGET_LICENSE_FILE}"
