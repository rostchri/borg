# Helper for Tabs
require 'kickstrap/menu_tabs_helper'
ActionView::Base.send :include, MenuTabsHelper

# Helper for Collapsible Groups
require 'kickstrap/collapsible_group_helper'
ActionView::Base.send :include, CollapsibleGroupHelper

# Helper for Modal Dialog
require 'kickstrap/modal_helper'
ActionView::Base.send :include, ModalHelper

# Helper for Buttons
require 'kickstrap/button_helper'
ActionView::Base.send :include, ButtonHelper
