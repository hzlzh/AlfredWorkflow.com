class Hatmaker::Workflow
  attr_reader :author, :description, :download_link, :name, :version

  def initialize(params)
    @author        = params['author']
    @description   = params['description']
    @download_link = params['download_link']
    @name          = params['name']
    @version       = params['version']
  end

  def self.search(query)
    query = Regexp.escape(query)

    @workflows ||= self.all
    @workflows.select { |w| w.name =~ /#{query}/i }
  end

  private

  def self.all
    AlfredWorkflow.all
  end
end
