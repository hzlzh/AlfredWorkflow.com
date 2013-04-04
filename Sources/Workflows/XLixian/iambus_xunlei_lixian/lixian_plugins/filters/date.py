
from lixian_plugins.api import task_filter

@task_filter(pattern=r'^\d{4}[-.]\d{2}[-.]\d{2}$')
def filter_by_date(keyword, task):
	return task['date'] == keyword.replace('-', '.')

