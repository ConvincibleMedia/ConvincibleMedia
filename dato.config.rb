# Helpers
def ifdef (x, y = '')
	defined?(x) ? x : y
end

#Site Settings
social_profiles = dato.social_profiles.map do |profile|
{
	type: profile.name.downcase.gsub(/ +/, '-'),
	link: profile.link
}
end
sep = '|'
suf = ''
if defined?(dato.site.global_seo.title_suffix)
	suf = dato.site.global_seo.title_suffix
	sep2 = suf.match(/^\s*([^\w\s\d]{1,2})\s*/)
	if sep2 != nil
		sep = sep2[1]
		suf2 = suf.match(/^\s*[^\w\s\d]{1,2}\s*(.+)\s*$/)
		if suf2 != nil
			suf = suf2[1]
		end
	end
end
if suf == sep then suf = '' end
create_data_file "source/_data/settings.yml", :yaml,
	name: dato.site.global_seo.site_name,
	seo: {
		title: dato.site.global_seo.fallback_seo.title,
		description: dato.site.global_seo.fallback_seo.description,
		image: dato.site.global_seo.fallback_seo.image,
		separator: sep,
		suffix: suf
	},
	language: dato.site.locales.first,
	social_profiles: social_profiles,
	footer: dato.home.footer
	
create_data_file "source/_data/favicon.yml", :yaml,
	dato.site.favicon_meta_tags
	
	
#Home Page
home = dato.home
create_post "source/index.md" do
	frontmatter(
		:yaml,
		layout: 'index',
		tagline: home.tagline,
		hero_image_src: home.hero_image.url,
		services: home.services.map do |item|
		{
			name: item.name,
			description: defined?(item.seo.description) ? item.seo.description : '',
			link: item.slug
		}
		end,
		quotes: home.quote.to_hash,
		showcase: home.showcase.map do |item|
		{
			image: defined?(item.hero_image.url) ? item.hero_image.url : '',
			name: item.name,
			description: defined?(item.seo.description) ? item.seo.description : '',
			link: item.slug
		}
		end,
		approach: home.approach,
		contact: home.contact.map do |item|
		{
			title: item.title,
			pre_title: item.pre_title,
			button: item.button,
			link: item.slug
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
				collection: 'services',
				order: index + 1,
				name: item.name,
				seo: item.seo,
				hero_image_src: defined?(item.hero_image.url) ? item.hero_image.url : '',
				heading: item.heading.to_hash,
				intro: item.intro.to_hash,
				elements_heading: item.elements_heading,
				elements: item.elements.to_hash,
				elements_note: item.elements_note,
				subservices_heading: item.sub_services_heading,
				subservices: item.sub_services.to_hash
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
				collection: 'showcase',
				order: index + 1,
				name: item.name,
				seo: item.seo,
				hero_image_src: defined?(item.hero_image.url) ? item.hero_image.url : '',
				client: item.client,
				logo_image_src: defined?(item.logo.url) ? item.logo.url : '',
				heading: item.heading.to_hash,
				intro: item.intro.to_hash,
				facets: item.facets.to_hash,
				quote: {
					paragraphs: item.quote,
					cite: item.quote_source
				},
				services: item.services.map do |item|
				{
					name: item.name,
					description: defined?(item.seo.description) ? item.seo.description : '',
					link: item.slug
				}
				end
			}
		end
	end
end

#Contact
directory "source/_contact" do
	dato.contacts.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'contact',
				collection: 'contact',
				order: index + 1,
				seo: item.seo,
				pre_title: item.pre_title,
				title: item.title,
				button: item.button
			}
		end
	end
end