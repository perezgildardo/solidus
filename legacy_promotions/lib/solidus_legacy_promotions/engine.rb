# frozen_string_literal: true

module SolidusLegacyPromotions
  class Engine < ::Rails::Engine
    include SolidusSupport::EngineExtensions
    MenuItem = Spree::BackendConfiguration::MenuItem

    initializer "solidus_legacy_promotions.add_menu_item" do
      promotions_menu_item = MenuItem.new(
        label: :promotions,
        icon: Spree::Backend::Config.admin_updated_navbar ? "ri-megaphone-line" : "bullhorn",
        partial: "spree/admin/shared/promotion_sub_menu",
        condition: -> { can?(:admin, Spree::Promotion) },
        url: :admin_promotions_path,
        data_hook: :admin_promotion_sub_tabs,
        children: [
          MenuItem.new(
            label: :promotions,
            condition: -> { can?(:admin, Spree::Promotion) }
          ),
          MenuItem.new(
            label: :promotion_categories,
            condition: -> { can?(:admin, Spree::PromotionCategory) }
          )
        ]
      )
      product_menu_item_index = Spree::Backend::Config.menu_items.find_index { |item| item.label == :products }
      Spree::Backend::Config.menu_items.insert(product_menu_item_index + 1, promotions_menu_item)
    end

    initializer "solidus_legacy_promotions.add_solidus_admin_menu_items" do
      if SolidusSupport.admin_available?
        SolidusAdmin::Config.configure do |config|
          config.menu_items << {
            key: "promotions",
            route: -> { spree.admin_promotions_path },
            icon: "megaphone-line",
            position: 30
          }
        end
      end
    end

    initializer "solidus_legacy_promotions.assets" do |app|
      app.config.assets.precompile << "solidus_legacy_promotions/manifest.js"
    end
  end
end
