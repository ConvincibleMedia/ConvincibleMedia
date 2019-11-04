#Site Settings
puts 'Social profiles...'

social_profiles = {}
dato.social_profiles.each { |profile|
	social_profiles[profile.id] = {
		type: profile.name.downcase.gsub(/ +/, '-'),
		name: profile.name,
		link: profile.link,
		icon: defined?(profile.icon.url) ? profile.icon.to_hash.slice(:url) : '',
		cta: profile.call_to_action
	}
}

puts 'Site settings...'

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


################################################################################

puts 'Create sitemap...'

#Sitemap
sitemap = {
	models: Hash.new,
	pages: Hash.new,
	tree: Hash.new,
	types: Hash.new
}

#Shorthands
home = dato.home #Single
services = dato.services #Multiple
showcases = dato.showcases #Multiple
contact = dato.contact_pages #Multiple
clients = dato.clients #Multiple
examples = dato.examples #Multiple
articles = dato.articles #Multiple
models = [ services, showcases, contact, clients, examples, articles ]

#Root pages
rootpages = { #List hard-coded root pages
	services: 'Services',
	showcase: 'Showcase',
	contact: 'Contact',
	articles: 'Free Thinking'
}

#MODELS = API Keys
#------------------------
sitemap[:models] = {
	home: { path: ''},
	service: { path: ''},
	showcase: { path: 'showcase/'},
	contact_page: { path: 'contact/'},
	client: { path: 'client/' },
	example: { path: 'example/' },
	article: { path: 'article/' }
}

#IDs
#------------------------
puts 'Root pages...'
#Root
sitemap[:pages][home.id] = {
	title: 'Home',
	slug: '',
	path: '/',
	fullpath: '/',
	type: 'home',
	order: 1,
	live: true
}
rootpages.each_with_index { |(slug, title), index|
	sitemap[:pages][slug.to_s.prepend('@').to_sym] = {
		title: title.to_s,
		slug: slug.to_s,
		path: '/',
		fullpath: '/' + slug.to_s + '.html',
		type: '',
		order: index + 2,
		live: true
	}
}
#Inside pages - Iterate
puts 'Inside pages...'
models.each { |model|
	model.each_with_index {|item, index|
		path = sitemap[:models][item.item_type.api_key.to_sym][:path]
		sitemap[:pages][item.id] = {
			title: defined?(item.name) ? item.name : item.title.to_s,
			slug: item.slug,
			path: '/' + path,
			fullpath: '/' + path + item.slug + '.html',
			type: item.item_type.api_key,
			order: index + 1,
			live: defined?(item.live) ? (item.live == true ? true : false) : true
		}
	}
}

#Map
#------------------------
#Root
=begin
sitemap[:tree][:root] = {
	pages: [ home.id ].push(rootpages.map{|k,v| k.to_s.prepend('@')}),
	paths: sitemap[:models].map{ |h| h.except!(:home) }.map{ |k,v| k[:path] },
	parent: 'root'
}
=end

puts 'Tree map...'
sitemap[:tree] = {
	root: {
		index: home.id,
		pages: [],
		below: [ 'services', 'showcase' ],
		above: 'root'
	},
	services: {
		index: '@services',
		pages: [ 'id', 'id' ],
		below: [],
		above: 'root'
	},
	showcase: {
		index: '@showcase',
		pages: [ 'id', 'id' ],
		below: [],
		above: 'root'
	},
	articles: {
		index: '@articles',
		pages: [ 'id', 'id' ],
		below: [],
		above: 'root'
	},
	contact: {
		index: '@contact',
		pages: [ 'id', 'id' ],
		below: [],
		above: 'root'
	}
}

=begin
path_root:
  pages:
  - id
  - id
  - id
  children:
  - services
  - showcase
  - contact
  parent: root
path_services:
  pages:
  - branding
  - presentations
  - websites
  children:
  - websites
  parent: root
path_services_websites:
  pages:
  - id
  subpaths: []
  parent: services
=end


create_data_file "source/_data/sitemap.yml", :yaml,
	sitemap


################################################################################

puts 'Home page...'

#Home Page
create_post "source/index.md" do
	frontmatter(
		:yaml,
		layout: 'index',
		live: true,
		link: home.id,
		tagline: home.tagline,
		image: home.hero_image.to_hash.slice(:url, :alt, :title),
		blurb: home.blurb,
		featured: home.featured.to_hash.map { |item|
			{
				subtitle:
					case item[:item_type]
					when "service"
						'New Service: ' + item[:name]
					when "showcase"
						'New Case Study'
					else
						'New ' + item[:item_type].capitalize
					end,
				text:
					case item[:item_type]
					when "service"
						item[:description]
					when "showcase"
						item[:heading].map{ |h| h[:text] }.join(" ").sub(/\.$/,'')
					else
						item[:title] || item[:name]
					end,
				link: item[:id],
				image:
					if defined?(item[:hero_image][:url])
						item[:hero_image].to_hash.slice(:url, :alt, :title)
					elsif defined?(item[:image][:url])
						item[:image].to_hash.slice(:url, :alt, :title)
					else
						''
					end
			}
		},
		services: home.services.to_hash.map { |item|
			{
				name: item[:name],
				description: item[:description],
				link: item[:id],
				live: item[:live],
				image: defined?(item[:hero_image][:url]) ? item[:hero_image].to_hash.slice(:url, :alt, :title) : '',
			}
		},
		quotes: home.quote.to_hash.map{ |h| h.except!(:id, :updated_at) },
		showcase: home.showcase.to_hash.map { |item|
			{
				tagline: item[:heading].map{ |h| h[:text] }.join(" ").sub(/\.$/,''),
				image: defined?(item[:hero_image][:url]) ? item[:hero_image].to_hash.slice(:url, :alt, :title) : '',
				logo: defined?(item[:client][:logo][:url]) ? item[:client][:logo].to_hash.slice(:url, :alt, :title) : '',
				description: item[:description],
				link: item[:id]
			}
		},
		clients: home.clients.to_hash.map { |item|
			{
				name: item[:name],
				logo: defined?(item[:logo][:url]) ? item[:logo].to_hash.slice(:url, :alt, :title) : '',
				link: item[:id]
			}
		},
		approach: home.approach
	)
end

puts 'Each service...'

#Services
directory "source/_services" do
	services.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'services',
				collection: 'services',
				live: defined?(item.live) ? (item.live == true ? true : false) : true,
				link: item.id,
				order: index + 1,
				name: item.name,
				title: item.heading.to_hash.map{ |h| h[:text] }.join(" ").sub(/\.$/,''),
				slug: item.slug,
				seo: defined?(item.seo) && !item.seo.nil? ? item.seo.to_hash.slice(:title, :description, :image) : '',
				description: item.description,
				image: defined?(item.hero_image.url) ? item.hero_image.to_hash.slice(:url, :alt, :title) : '',
				heading: item.heading.to_hash.map{ |h| h.except!(:id, :updated_at) },
				intro: item.intro.to_hash.map{ |h| h.except!(:id, :updated_at) },
				examples: item.examples.to_hash.map { |h|
					if h[:item_type] == "example" && h[:gallery].size > 0 && h[:gallery][0][:url].length > 0
						{
							image: h[:gallery][0].slice(:url, :alt, :title),
							link: h[:id]
						}
					elsif h[:item_type] == "showcase" && h[:hero_image][:url].length > 0
						{
							image: h[:hero_image].slice(:url, :alt, :title),
							link: h[:id]
						}
					end
				},
				elements_heading: item.elements_heading,
				elements: item.elements.to_hash.map{ |h| h.except!(:id, :updated_at) },
				elements_note: item.elements_note,
				subservices_heading: item.sub_services_heading,
				subservices: item.sub_services.to_hash.map{ |h| h.except!(:id, :updated_at) }
			}
		end
	end
end


puts 'Each example...'

#Examples
directory "source/_examples" do
	examples.each_with_index do |item, index|
		of = item.of.to_hash.map { |item|
			{
				title: item[:name],
				description: item[:description],
				link: item[:id]
			}
		}
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'example',
				collection: 'examples',
				link: item.id,
				order: index + 1,
				name: item.title,
				title: item.title,
				slug: item.slug,
				gallery: item.gallery.to_hash.map { |h| h.slice(:url, :alt, :title) },
				client: {
					name: item.client.name,
					logo: defined?(item.client.logo.url) ? item.client.logo.to_hash.slice(:url, :alt, :title) : '',
					link: item.client.id
				},
				of: of,
				service: of[0][:title]
			}
			content(item.information)
		end
	end
end

puts 'Each showcase...'

#Showcase
directory "source/_showcase" do
	showcases.each_with_index do |item, index|
		puts index.to_s
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'showcase',
				collection: 'showcase',
				live: defined?(item.live) ? (item.live == true ? true : false) : true,
				published: defined?(item.live) ? (item.live == true ? true : false) : true,
				link: item.id,
				order: index + 1,
				name: item.name,
				title: item.name + (defined?(item.client.name) ? ' ' + sep + ' ' + item.client.name : ''),
				tagline: item.heading.to_hash.map{ |h| h[:text] }.join(" ").sub(/\.$/,''),
				slug: item.slug,
				seo: defined?(item.seo) && !item.seo.nil? ? item.seo.to_hash.slice(:title, :description, :image) : '',
				description: item.description,
				image: defined?(item.hero_image.url) ? item.hero_image.to_hash.slice(:url, :alt, :title) : '',
				client: defined?(item.client.name) ? {
					name: item.client.name,
					logo: defined?(item.client.logo.url) ? item.client.logo.to_hash.slice(:url, :alt, :title) : '',
					link: item.client.id
				} : { name: '', logo: '', link: ''},
				logo: defined?(item.client.logo.url) ? item.client.logo.to_hash.slice(:url, :alt, :title) : '',
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

puts 'Each client...'

#Clients
directory "source/_clients" do
	clients.each_with_index do |item, index|
		puts index.to_s
		create_post "#{item.slug}.md" do
			frontmatter :yaml, {
				layout: 'clients',
				collection: 'clients',
				live: defined?(item.live) ? (item.live == true ? true : false) : true,
				published: defined?(item.live) ? (item.live == true ? true : false) : true,
				link: item.id,
				order: index + 1,
				name: defined?(item.name) ? item.name : '',
				title: defined?(item.name) ? item.name : '',
				slug: item.slug,
				seo: defined?(item.seo) && !item.seo.nil? ? item.seo.to_hash.slice(:title, :description, :image) : '',
				logo: defined?(item.logo.url) ? item.logo.to_hash.slice(:url, :alt, :title) : '',
				client_url: item.url,
				projects: showcases.select{ |showcase| showcase.client.name == item.name && showcase.live == true }.map { |project|
					{
						title: project.heading.to_hash.map{ |h| h[:text] }.join(" ").sub(/\.$/,''),
						subtitle: project.name,
						description: project.description,
						image: defined?(project.hero_image.url) ? project.hero_image.to_hash.slice(:url, :alt, :title) : '',
						link: project.id
					}
				} + examples.select { |example| example.client.name == item.name }.map { |project|
					{
						title: project.title,
						subtitle: project.of.to_hash[0][:name],
						image: project.gallery.to_hash[0].slice(:url, :alt, :title),
						link: project.id
					}
				}
			}
			content(item.description)
		end
	end
end

puts 'Approach data...'

#Approach
create_data_file "source/_data/approach.yml", :yaml,
	lead: dato.approach.lead,
	point_1: dato.approach.point_1,
	point_2: dato.approach.point_2,
	point_3: dato.approach.point_3

puts 'Contact data...'

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

puts 'Each contact page...'

directory "source/_contact" do
	contact.each_with_index do |item, index|
		create_post "#{item.slug}.md" do
			fm = {
				layout: 'contact',
				collection: 'contact',
				live: defined?(item.live) ? (item.live == true ? true : false) : true,
				link: item.id,
				order: index + 1,
				seo: defined?(item.seo) && !item.seo.nil? ? item.seo.to_hash.slice(:title, :description, :image) : '',
				options: item.options.map do |item|
					{
						icon: item.icon,
						name: item.name,
						details: item.details,
						explanation: item.explanation
					}
				end,
				form_id: item.form_id
			}
			fm[:features] = ['form'] if fm[:form_id].strip.length > 0
			frontmatter :yaml, fm
			content(item.intro)
		end
	end
end

# Articles

puts 'Each article...'

block_types = {
	'block_body_lead' => [
		:paragraphs
	],
	'block_body_text' => [
		:text
	],
	'block_body_section' => [
		:header,
		:image,
		:lead
	],
	'block_body_image' => [
		:image, :caption
	]
}

directory "source/_articles" do
	articles.each_with_index do |item, index|
		date = item.date.strftime('%F')
		create_post "#{date}-#{item.slug}.md" do
			fm = {
				layout: 'article',
				collection: 'articles',
				title: item.title,
				slug: item.slug,
				link: item.id,
				seo: defined?(item.seo) && !item.seo.nil? ? item.seo.to_hash.slice(:title, :description, :image) : '',
				excerpt: item.abstract,
				image: defined?(item.image.url) ? item.image.to_hash.slice(:url, :alt, :title) : '',
				authors: item.authors.to_hash.map { |item|
					{
						name: item[:display_name],
						role: item[:job_title],
						image: defined?(item[:photo][:url]) ? item[:photo].to_hash.slice(:url, :alt, :title) : '',
					}
				},
				services: item.services.to_hash.map { |item|
					{
						title: item[:name],
						description: item[:description],
						link: item[:id]
					}
				},
				question: item.question,
				shares: item.shares.to_hash.map { |item|
					{
						profile: item[:profile][:id],
						link: item[:link]
					}
				}
			}
			body = ''
			length = 0
			item.body.to_hash.map{ |h| h.except!(:id, :updated_at, :created_at) }.each { |block|
				if block_types.key?(block[:item_type])
					body += '<div class="' + block[:item_type] + '" markdown="1">' + "\n\n"
					if block[:item_type] == 'block_body_image'
						body += "<figure>\n"
						body += "{% include helpers/img.html src='#{block[:image][:url]}' format=site.data.images.gallery %}"
						if defined?(block[:caption]) && block[:caption].size > 0
							body += "\n\n"
							body += "<figcaption>\n#{block[:caption]}\n</figcaption>"
						end
						body += "\n</figure>\n\n"
					else
						block_types[block[:item_type]].each { |field|
							case field
							when :image
								this = ''
								this = "<figure>{% include helpers/img.html src='#{block[:image][:url]}' format=site.data.images.gallery %}</figure>" if defined?(block[:image][:url])
							else
								this = block[field].to_s.strip
								length += this.split(/\s+/).length
							end
							body += this + "\n\n"
						}
					end
					body += '</div>' + "\n\n"
				end
			}
			fm[:words] = length
			frontmatter :yaml, fm
			content(body)
		end
	end
end
