Wikicausality::Application.config.middleware.use ExceptionNotifier, :email_prefix => "[ERROR] ", :sender_address => "donotreply@thiscausesthat.org", :exception_recipients =>["randomemailaddress"], :ignore_crawlers => %w{Googlebot bingbot}

