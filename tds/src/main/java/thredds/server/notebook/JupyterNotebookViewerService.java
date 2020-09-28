package thredds.server.notebook;

import gov.noaa.pmel.sgt.MethodNotImplementedError;
import thredds.client.catalog.Dataset;
import thredds.core.StandardService;
import thredds.server.config.TdsContext;
import thredds.server.viewer.Viewer;
import thredds.server.viewer.ViewerLinkProvider;
import thredds.server.viewer.ViewerService;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Formatter;
import java.util.List;

public class JupyterNotebookViewerService implements ViewerService {

  private JupyterNotebookServiceCache jupyterNotebooks;

  private String contentDir;

  private List<Viewer> viewers = new ArrayList<>();

  public JupyterNotebookViewerService(JupyterNotebookServiceCache jupyterNotebooks, String contentDir) {
    this.jupyterNotebooks = jupyterNotebooks;
    this.contentDir = contentDir;
    this.buildViewerList();
  }

  @Override
  public List<Viewer> getViewers() {
    return viewers;
  }

  @Override
  public Viewer getViewer(String viewer) {
    return null;
  }

  @Override
  public String getViewerTemplate(String template) {
    throw new MethodNotImplementedError();
  }

  @Override
  public boolean registerViewer(Viewer v) {
    return viewers.add(v);
  }

  @Override
  public boolean registerViewers(List<Viewer> v) {
    return viewers.addAll(v);
  }

  @Override
  public void showViewers(Formatter sbuff, Dataset dataset, HttpServletRequest req) {
    throw new MethodNotImplementedError();
  }

  @Override
  public List<ViewerLinkProvider.ViewerLink> getViewerLinks(Dataset dataset, HttpServletRequest req) {
    return null;
  }

  private void buildViewerList() {
    jupyterNotebooks.getAllNotebooks()
        .forEach(notebook -> registerViewer(new JupyterNotebookViewer(notebook, contentDir)));
  }

  public static class JupyterNotebookViewer implements Viewer {

    private static final ViewerLinkProvider.ViewerLink.ViewerType type =
        ViewerLinkProvider.ViewerLink.ViewerType.JupyterNotebook;

    private String contentDir;

    private NotebookMetadata notebook;

    public JupyterNotebookViewer(NotebookMetadata notebook, String contentDir) {
      this.notebook = notebook;
      this.contentDir = contentDir;
    }

    public boolean isViewable(Dataset ds) {
      return notebook.isValidForDataset(ds);
    }

    public String getViewerLinkHtml(Dataset ds, HttpServletRequest req) {
      ViewerLinkProvider.ViewerLink viewerLink = this.getViewerLink(ds, req);
      return "<a href='" + viewerLink.getUrl() + "'>" + viewerLink.getTitle() + "</a>";
    }

    public ViewerLinkProvider.ViewerLink getViewerLink(Dataset ds, HttpServletRequest req) {
      String catUrl = ds.getCatalogUrl();
      if (catUrl.indexOf('#') > 0)
        catUrl = catUrl.substring(0, catUrl.lastIndexOf('#'));
      if (catUrl.indexOf(contentDir) > -1) {
        catUrl = catUrl.substring(catUrl.indexOf(contentDir) + contentDir.length());
      }
      String catalogServiceBase = StandardService.catalogRemote.getBase();
      catUrl =
          catUrl.substring(catUrl.indexOf(catalogServiceBase) + catalogServiceBase.length()).replace("html", "xml");

      String url = req.getContextPath() + StandardService.jupyterNotebook.getBase()
              + ds.getID() + "?catalog=" + catUrl + "&filename=" + notebook.getFilename();
      return new ViewerLinkProvider.ViewerLink(notebook.getFilename(), url, notebook.getDescription(), type);
    }
  }
}
