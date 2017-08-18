# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Add folder with webpack generated assets to assets.paths
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "webpack")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile << "server-bundle.js"

Rails.application.config.assets.precompile += ["main.js", 
    "fancybox.js",
    "vendor/fancybox/css/jquery.fancybox-buttons.css",
    "vendor/fancybox/css/jquery.fancybox-thumbs.css",
    "vendor/fancybox/css/jquery.fancybox.css",
    "vendor/fancybox/js/jquery.fancybox-buttons.js",
    "vendor/fancybox/js/jquery.fancybox-thumbs.js",
    "vendor/fancybox/js/jquery.fancybox.js",
	"vendor/owlcarousel/owl.carousel.min.js", 
	"vendor/owlcarousel/owl.carousel.css",
	"vendor/owlcarousel/css/animate.css",
	"vendor/bootstrap-select/bootstrap-select.min.js", 
	"vendor/bootstrap-select/css/bootstrap-select.min.css",
	"vendor/bootstrap/css/bootstrap.min.css",
	"vendor/revolution/js/jquery.themepunch.tools.min.js",
	"vendor/revolution/js/jquery.themepunch.revolution.min.js",
	"vendor/revolution/js/extensions/revolution.extension.actions.min.js",
	"vendor/revolution/js/extensions/revolution.extension.carousel.min.js",
	"vendor/revolution/js/extensions/revolution.extension.kenburn.min.js",
	"vendor/revolution/js/extensions/revolution.extension.layeranimation.min.js",
    "vendor/revolution/js/extensions/revolution.extension.migration.min.js",
    "vendor/revolution/js/extensions/revolution.extension.navigation.min.js",
    "vendor/revolution/js/extensions/revolution.extension.parallax.min.js",
    "vendor/revolution/js/extensions/revolution.extension.slideanims.min.js",
    "vendor/revolution/js/extensions/revolution.extension.video.min.js",
    "homepage.js",
    "theme.js",
    "vendor/revolution/css/settings.css",
    "vendor/revolution/css/layers.css",
    "vendor/revolution/css/navigation.css",
    "vendor/easy-responsive-tabs/css/easy-responsive-tabs.css",
    "vendor/easy-responsive-tabs/css/easy-responsive-tabs.css",
    "vendor/owlcarousel/css/animate.css",
    "vendor/easy-responsive-tabs/js/easyResponsiveTabs.js",
    "FontAwesome.otf",
    "fontawesome-webfont.eot",
    "fontawesome-webfont.svg",
    "fontawesome-webfont.ttf",
    "fontawesome-webfont.woff",
    "css/theme-contactus.css",
    "vendor/jquery.gmap/jquery.gmap.min.js",
    "origin_responsive.css",
	"application.js", "application_reactpage.js", "application.css", "react_page/styles.css"]

PluginRoutes.system_info["relative_url_root"] = 'blog'
