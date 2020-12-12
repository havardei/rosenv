# Configuration file for ipython-notebook.

c = get_config()

# ------------------------------------------------------------------------------
# NotebookApp configuration
# ------------------------------------------------------------------------------

c.IPKernelApp.pylab = 'inline'
c.NotebookApp.ip = '*'
c.NotebookApp.quit_button = False
c.NotebookApp.port = 8888
c.NotebookApp.notebook_dir = '/home/notebook'
c.NotebookApp.allow_origin = '*'

c.LauncherShortcuts.shortcuts = {
    'desktop': {
        'title': 'Desktop',
        'target': '{base_url}/desktop',
        'icon_path': ''
    }
}

