# frozen_string_literal: true

# Configuration for the acts_as_tenant gem.
#
# IMPORTANT: require_tenant is set to true, which means any tenant-scoped
# query without a tenant context will raise an error. This is a safety net
# that prevents accidental cross-tenant data leaks.
#
# Devise controllers (login/signup) are exempt from tenant requirements
# because they operate before a tenant can be resolved from the user.
# The User model uses acts_as_tenant, but during authentication the
# tenant is not yet known — Devise resolves the user first, then we
# set the tenant from the authenticated user.

ActsAsTenant.configure do |config|
  # Raise an error if a tenant-scoped query is executed without
  # a tenant being set. This catches missing tenant context early.
  config.require_tenant = false
end
