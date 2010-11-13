require 'action_view'
require 'ms_form/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'ms_form/form_helper'
module MsForm
  autoload :FormBuilder, 'ms_form/form_builder'
end
require 'tbl_form/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'tbl_form/form_helper'
module TblForm
  autoload :FormBuilder, 'tbl_form/form_builder'
end
