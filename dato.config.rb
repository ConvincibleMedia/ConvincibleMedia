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


#Sitemap
sitemap = {
	models: Hash.new,
	pages: Hash.new,
	types: Hash.new,
	map: Hash.new
}

home = dato.home #Single
services = dato.services #Multiple
showcases = dato.showcases #Multiple
contact = dato.contact_pages #Multiple

#Models
sitemap[:models] = {
	home: { path: ''},
	service: { path: 'services/'},
	showcase: { path: 'showcase/'},
	contact_page: { path: 'contact/'},
	'': { path: '' }
}

#IDs
sitemap[:pages][home.id] = {
	title: 'Home',
	slug: '',
	path: '/',
	fullpath: '/',
	type: 'home',
	order: 1
}
#Manual
rootpages = {
	services: 'Services',
	showcase: 'Showcase',
	contact: 'Contact'
}
rootpages.each_with_index { |(slug, title), index|
	sitemap[:pages][slug.to_s.prepend('@').to_sym] = {
		title: title.to_s,
		slug: slug.to_s,
		path: '/',
		fullpath: '/' + slug.to_s + '.html',
		type: '',
		order: index + 2
	}
}
#Iterate
models = [ services, showcases, contact ]
models.each { |model|
	model.each_with_index {|item, index|
		path = sitemap[:models][item.item_type.api_key.to_sym][:path]
		sitemap[:pages][item.id] = {
			title: item.name,
			slug: item.slug,
			path: '/' + path,
			fullpath: '/' + path + item.slug + '.html',
			type: item.item_type.api_key,
			order: index + 1
		}
	}
}
create_data_file "source/_data/sitemap.yml", :yaml,
	sitemap


#Home Page
create_post "source/index.md" do
	frontmatter(
		:yaml,
		layout: 'index',
		link: home.id,
		tagline: home.tagline,
		image: home.hero_image.url,
		services: home.services.to_hash.map { |item|
			{
				name: item[:name],
				description: item[:description],
				link: item[:id],
				live: item[:live]
			}
		},
		quotes: home.quote.to_hash.map{ |h| h.except!(:id, :updated_at) },
		showcase: home.showcase.to_hash.map { |item|
			{
				image: defined?(item[:hero_image][:url]) ? item[:hero_image][:url] : '',
				logo: defined?(item[:logo][:url]) ? item[:logo][:url] : '',
				title: item[:heading].map{ |h| h[:text] }.join(" "),
				description: item[:description],
				link: item[:id]
			}
		},
		approach: home.approach
	)
end


#Services
directory "source/_services" do
	services.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'services',
				collection: 'services',
				live: item.live,
				link: item.id,
				order: index + 1,
				name: item.name,
				title: item.heading.to_hash.map{ |h| h[:text] }.join(" "),
				slug: item.slug,
				seo: item.seo,
				description: item.description,
				image: defined?(item.hero_image.url) ? item.hero_image.url : '',
				heading: item.heading.to_hash.map{ |h| h.except!(:id, :updated_at) },
				intro: item.intro.to_hash.map{ |h| h.except!(:id, :updated_at) },
				elements_heading: item.elements_heading,
				elements: item.elements.to_hash.map{ |h| h.except!(:id, :updated_at) },
				elements_note: item.elements_note,
				subservices_heading: item.sub_services_heading,
				subservices: item.sub_services.to_hash.map{ |h| h.except!(:id, :updated_at) }
			}
		end
	end
end


#Showcase
directory "source/_showcase" do
	showcases.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'showcase',
				collection: 'showcase',
				link: item.id,
				order: index + 1,
				name: item.name,
				title: item.heading.to_hash.map{ |h| h[:text] }.join(" "),
				slug: item.slug,
				seo: item.seo,
				description: item.description,
				image: defined?(item.hero_image.url) ? item.hero_image.url : '',
				client: item.client,
				logo: defined?(item.logo.url) ? item.logo.url : '',
				heading: item.heading.to_hash.map{ |h| h.except!(:id, :updated_at) },
				intro: item.intro.to_hash.map{ |h| h.except!(:id, :updated_at) },
				facets: item.facets.to_hash.map{ |h| h.except!(:id, :updated_at) },
				quote: {
					paragraphs: item.quote,
					cite: item.quote_source
				},
				services: item.services.to_hash.map { |item|
					{
						title: item[:name],
						description: item[:description],
						link: item[:id]
					}
				}
			}
		end
	end
end


#Approach
create_data_file "source/_data/approach.yml", :yaml,
	lead: dato.approach.lead,
	point_1: dato.approach.point_1,
	point_2: dato.approach.point_2,
	point_3: dato.approach.point_3


#Contact
contact_options = Hash.new
dato.contact_options.each { |item|
	contact_options[item.name.downcase] = {
		name: item.name,
		details: item.details,
		icon: item.icon
	}
}
contact_pages = { pages: Hash.new }
dato.contact.to_hash.each { |index, item|
	if (item.kind_of?(Array))
		contact_pages[:pages][index] = Array.new
		for card in item do
			contact_pages[:pages][index].push({
				pre_title: card[:pre_title],
				title: card[:title],
				button: card[:button],
				link: card[:link][:id]
			})
		end
	end
}

create_data_file "source/_data/contact.yml", :yaml,
	contact_options.merge(contact_pages)

directory "source/_contact" do
	contact.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'contact',
				collection: 'contact',
				link: item.id,
				order: index + 1,
				seo: item.seo,
				options: item.options.map do |item|
				{
					icon: item.icon,
					name: item.name,
					details: item.details,
					explanation: item.explanation
				}
			end
			}
			content(item.intro)
		end
	end
end
