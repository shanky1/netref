<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>

<%
    File file ;
    int maxFileSize = 5000 * 1024;
    int maxMemSize = 5000 * 1024;

//    ServletContext context = pageContext.getServletContext();
    String filePath = "D:/coref/web/profile_doc/";

    System.out.println(new Date()+"\t ===========");
    System.out.println(new Date()+"\t filePath: "+filePath);

    // Verify the content type
    String contentType = request.getContentType();

    System.out.println("contentType: "+contentType);

    if ((contentType.indexOf("multipart/form-data") >= 0)) {
        DiskFileItemFactory factory = new DiskFileItemFactory();
        // maximum size that will be stored in memory
        factory.setSizeThreshold(maxMemSize);
        // Location to save data that is larger than maxMemSize.
        factory.setRepository(new File("c:\\temp"));

        // Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);
        // maximum file size to be uploaded.
        upload.setSizeMax( maxFileSize );
        try {
            // Parse the request to get file items.
            List fileItems = upload.parseRequest(request);

            System.out.println("fileItems.size(): "+fileItems.size());

            // Process the uploaded file items
            Iterator i = fileItems.iterator();
            long timeMillis = System.currentTimeMillis();

            while ( i.hasNext () ) {
                FileItem fi = (FileItem)i.next();

//                System.out.println("fi isFormField: "+fi.isFormField());
//                System.out.println("fi name: "+fi.getName());

                if ( !fi.isFormField () ) {
                    // Get the uploaded file parameters
                    String fieldName = fi.getFieldName();
                    String fileName = fi.getName();
                    boolean isInMemory = fi.isInMemory();
                    long sizeInBytes = fi.getSize();

                    // Write the file
                    if( fileName.lastIndexOf("\\") >= 0 ) {
                        file = new File(filePath + ""+timeMillis+"_"+fileName.substring(fileName.lastIndexOf("\\"))) ;
                        out.print(fileName.substring(fileName.lastIndexOf("\\")));
                    } else {
                        file = new File(filePath + ""+timeMillis+"_"+fileName.substring(fileName.lastIndexOf("\\")+1)) ;
                        out.print(fileName.substring(fileName.lastIndexOf("\\")+1));
                    }

                    fi.write( file ) ;
                    System.out.println("Uploaded Filename: " + filePath + fileName + "<br>");

                    session.setAttribute("profile_doc", fileName);
                    session.setAttribute("profile_doc_uploaded_time", timeMillis+"");
                }
            }
        } catch(Exception ex) {
            System.out.println(ex);
        }
    } else {
        out.print("Please try again...");
    }
%>
