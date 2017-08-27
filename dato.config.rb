#Site Settings
social_profiles = dato.social_profiles.map do |profile|
{
	type: profile.name.downcase.gsub(/ +/, '-'),
	link: profile.link
}
end
create_data_file "source/_data/settings.yml", :yaml,
	name: dato.site.global_seo.site_name,
	globalseo: dato.site.global_seo.to_hash,
	language: dato.site.locales.first,
	copyright: dato.home.copyright,
	social_profiles: social_profiles,
	favicon_meta_tags: dato.site.favicon_meta_tags

#Home Page
home = dato.home
create_post "source/index.md" do
	frontmatter(
		:yaml,
		layout: 'index',
		name: home.name,
		seo: home.seo,
		tagline: home.tagline,
		hero_image_src: home.hero_image.url,
		services: home.services.map do |item|
		{
			name: item.name,
			description: item.seo,
			link: item.slug
		}
		end,
		showcase: home.showcase.map do |item|
		{
			name: item.name,
			description: item.seo,
			link: item.slug
		}
		end,
		approach: home.approach.map do |item|
		{
			name: item.name,
			description: item.description
		}	
		end
	)
end

#Services
directory "source/_services" do
	dato.services.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'services',
				order: index + 1,
				name: item.name,
				seo: item.seo,
				heading: item.heading.to_hash,
				body: item.body.to_hash
			}
		end
	end
end

#Showcase
directory "source/_showcase" do
	dato.showcases.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'showcase',
				order: index + 1,
				name: item.name,
				seo: item.seo,
				heading: item.heading.to_hash,
				body: item.body.to_hash
			}
		end
	end
end