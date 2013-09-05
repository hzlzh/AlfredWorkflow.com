class AlfredWorkflow
  URL = 'https://raw.github.com/hzlzh/AlfredWorkflow.com/master/workflow-api.json'

  def self.all
    json = open(URL).read
    Oj.load(json).map { |data| Hatmaker::Workflow.new parse_workflow data }
  end

  private

  def self.parse_workflow(data)
    {
      'author'        => data['workflow-author-name'],
      'description'   => data['workflow-description-small'],
      'download_link' => data['workflow-download-link'],
      'filename'      => 'workflow.alfredworkflow',
      'name'          => data['workflow-name'],
      'version'       => data['workflow-version']
    }
  end
end
