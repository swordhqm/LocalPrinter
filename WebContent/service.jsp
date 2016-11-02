<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- Set the content disposition header --%>
<%
	response.addHeader("Access-Control-Allow-Origin", "*");
%>
<%@ page import="javax.print.*"%>
<%@ page import="javax.print.attribute.*"%>
<%@ page import="javax.print.attribute.standard.*"%>
<%@ page import="org.apache.pdfbox.pdmodel.*"%>
<%@ page import="org.apache.pdfbox.printing.*"%>
<%@ page import="org.json.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*"%>
<%@ page import="java.net.*"%>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import="java.awt.print.*" %>

<%!
	public class PrintParameter {
		public class Param {
			String type;
			String sub_type;
			String file_name;
			String page_number_range;
			String count;
			byte[] file_content;
		}
		String why;
		ArrayList<Param> params = new ArrayList<Param>();
		
		/*
    	    [
   	    		{
 	    			"type": "Location",
 	    			"sub_type": "t1(4x2)",
 	    			"filename": "xx",
 	    			"page_number_range": "all",
 	    			"count": "2"
   	    		},
    	        {
    	            "type": "Label",
    	            "filename": "xx",
    	            "count":"2"
    	        },
    	        {
    	            "type": "Location",
    	            "doc_url": "http://www.baidu.com",
    	            "count": "2"
    	        },
    	        {
    	            "name": "FNSKU",
    	            "doc_url": "http://www.SoSo.com",
    	            "count": "2"
    	        }
    	    ]
	    */
		
		public void loadFromParamJsonStr(String json_str) {
	    	try {
		    	JSONArray _params = new JSONArray(json_str);
		    	//each JSONObject, find printer, print 
		    	for(int i = 0; i < _params.length(); i++) {
		    		Param p = new Param();
		    		JSONObject item = _params.getJSONObject(i);
		    		p.type = item.getString("type");
		    		p.sub_type = item.getString("sub_type");
		    		p.file_name= item.getString("file_name");
		    		p.page_number_range = item.getString("page_number_range");
		    		p.count = item.getString("count");
		    		params.add(p);
		    	}
	    	} catch (Exception e) {
	    		e.printStackTrace();
	    	}
		}
	    
	    public void loadFileToParam(String file_name, byte[] file_content) {
	    	for(int i = 0; i < params.size(); i++) {
	    		if(params.get(i).file_name.equals(file_name)) {
	    			params.get(i).file_content = file_content;
	    		}
	    	}
	    }
	    
	    public void dump() {
	    	for(int i = 0; i < params.size(); i++) {
	    		System.out.println("print param: " + params.get(i).type);
	    		System.out.println("print param: " + params.get(i).sub_type);
	    		System.out.println("print param: " + params.get(i).file_name);
	    		System.out.println("print param: " + params.get(i).page_number_range);
	    		System.out.println("print param: " + params.get(i).count);
	    		String s = new String(params.get(i).file_content);
	    		System.out.println("print param: " + s + "|length: " + params.get(i).file_content.length);
	    	}
	    }
	}

	public class Config {
		public class PrinterNode {
			String type;
			String sub_type;
			String position;
			String printer_name;
			String description;
			String pageType;
		}
		
		ArrayList<PrinterNode> printerNodes = new ArrayList<PrinterNode>();
		
		public void loadFromJsonArray(JSONArray config_json) {
			try {
				if(config_json != null) {
					for(int i = 0; i < config_json.length(); i++) {
						JSONObject config_node_json = config_json.getJSONObject(i);
						PrinterNode p = new PrinterNode();
						p.type = config_node_json.getString("type");
						p.sub_type = config_node_json.getString("sub_type");
						p.position = config_node_json.getString("position");
						p.printer_name = config_node_json.getString("printer_name");
						p.description = config_node_json.getString("description");
						p.pageType = config_node_json.getString("pageType");
						
						printerNodes.add(p);
					}
				}
			} catch (JSONException e) {
				
			}
		}
		
		public boolean successConfig() {
			if(printerNodes.size() > 0) {
				return true;
			} else {
				return false;
			}
		}
		
		public PrinterNode search(String type, String sub_type) {
			for(PrinterNode node : printerNodes) {
				System.out.println(node.type + "|" + type);
				System.out.println(node.sub_type + "|" + sub_type);
				
				if(node.type.equals(type) && node.sub_type.equals(sub_type)) {
					return node;
				}
				
			}
			
			return null;
		}
		
		public void loadFromConfigFile(HttpServletRequest request) {
			String _path = request.getRealPath("/");
			
			InputStreamReader fr = null;
			JSONArray config_json = null;
			try {
				BufferedReader in = new BufferedReader(new FileReader(_path + "config.txt"));
				//StringBuilder sb = new StringBuilder();
				String line;
				line = in.readLine();
				in.close();
				if(line != null) {
					config_json = new JSONArray(line);
				}
			} catch(IOException e) {
				
			} catch(JSONException e){
				
			} finally {
				
			}
			
			this.loadFromJsonArray(config_json);
			if(! this.successConfig()) {
				System.out.println("Config Fail~.......");
				return;
			}
		}
		
		public JSONArray getJSONArray(HttpServletRequest request) {
			String _path = request.getRealPath("/");
			
			JSONArray config_json = null;
			BufferedReader in = null;
			try {
				in = new BufferedReader(new FileReader(_path + "config.txt"));
				//StringBuilder sb = new StringBuilder();
				String line;
				line = in.readLine();
				in.close();
				if(line != null) {
					config_json = new JSONArray(line);
				}
			} catch(IOException e) {
			} catch(JSONException e){
				
			} finally {
			}
			
			return config_json;
		}
		
		public JSONArray getDefaultJSONArray(HttpServletRequest request) {
			JSONArray config_json = null;
			
			String default_config_json = "[" +
					"{"+
						"\"type\":\"Location\"," +
						"\"sub_type\":\"t1(4x2)\"," +
						"\"position\":\"localhost\"," +
						"\"printer_name\":\"ZDesigner LP 2844\"," +
						"\"description\":\"打印location\"," +
						"\"pageType\":\"4x2\"" +
					"}"+","+
					"{"+
						"\"type\":\"PalletLocation\"," +
						"\"sub_type\":\"t1(8.5x11)\"," +
						"\"position\":\"localhost\"," +
						"\"printer_name\":\"MF4800 Series\"," +
						"\"description\":\"PalletLocation\"," +
						"\"pageType\":\"letter\"" +
					"}"+
				"]";
			System.out.println(default_config_json);
			try {
				config_json = new JSONArray(default_config_json);
			} catch(Exception e) {
				e.printStackTrace();
			}
			return config_json;
		}
	}
	
	private void print(
		PrintParameter printParam, 
		HttpServletRequest request) {
		
		//load config
		String _path = request.getRealPath("/");
		System.out.println(_path);
		
		InputStreamReader fr = null;
		JSONArray config_json = null;
		try {
			BufferedReader in = new BufferedReader(new FileReader(_path + "config.txt"));
			//StringBuilder sb = new StringBuilder();
			String line;
			line = in.readLine();
			in.close();
			if(line != null) {
				config_json = new JSONArray(line);
			}
		} catch(IOException e) {
			
		} catch(JSONException e){
			
		} finally {
			
		}
		
		Config _config = new Config();
		_config.loadFromJsonArray(config_json);
		if(! _config.successConfig()) {
			System.out.println("Config Fail~.......");
			return;
		}
		
		for(int index = 0; index < printParam.params.size(); index++) {
			PrintParameter.Param p = printParam.params.get(index);
			Config.PrinterNode node = _config.search(p.type, p.sub_type);
			if(node == null) {
				System.out.println("Can't find the proper printer");
				return ;
			}
			
			if(node.position.equals("localhost")) {
				try {
					PrintService  printService = null;
					PrintService[] pServices = PrintServiceLookup.lookupPrintServices(null, null);
					if(pServices.length == 0) {
						System.out.println("No print service found.");
						return;
					}
					
					//define output stream
					FileOutputStream _o = null;
					_o = new FileOutputStream(_path + "out.pdf");
					
					//list printer
					if (pServices != null){
					    System.out.println("listing printers " + pServices.length);
					    
					    for (int i=0;i<pServices.length;i++){
				        	printService = pServices[i];
					    	System.out.println(pServices[i]);
				        }
					    System.out.println("listing end~");
					}
					
					//find printer
					boolean find = false;
					for (int i = 0; i < pServices.length; i++) {
						if(pServices[i].getName().equals(node.printer_name)) {
							System.out.println("*************************************************************");
							System.out.println("find printer: " + node.printer_name);
							System.out.println("**************************************************************");
							printService = pServices[i];
							find = true;
							break;
						}
					}
					if(!find) {
						_o.close();
						return;
					}
					
				 	PDDocument document = null;
					document = PDDocument.load(p.file_content);
					document.save(new File(_path + "xx.pdf"));
				 	
				 	PrinterJob job = PrinterJob.getPrinterJob();
				 	job.setPrintService(printService);
				 	
				 	//custom format & paper
				 	PageFormat pf = job.defaultPage();
					Paper paper = pf.getPaper();
					paper.setImageableArea(0, 0, paper.getWidth(), paper.getHeight());
					pf.setPaper(paper);
					pf.setOrientation(PageFormat.PORTRAIT);
					job.defaultPage(pf);
					
					//Book
					Book book = new Book();
					book.append(new PDFPrintable(document), pf, document.getNumberOfPages());
					
				 	job.setPageable(book);
				 	
				 	PrintRequestAttributeSet job_attrs = new HashPrintRequestAttributeSet();
				 	if(node.type.equals("Location") && node.sub_type.equals("t1(4x2)")) {
				 		//job_attrs.add(new MediaSize(2.00f, 4.00f, Size2DSyntax.INCH));
				 		job_attrs.add(new MediaPrintableArea(0, 0, 4, 2, MediaPrintableArea.INCH));
				 	}
				 	
				 	if(node.type.equals("PalletLocation") && node.sub_type.equals("t1(8.5x11)")) {
				 		
				 	}
				 	
					job.print(job_attrs);
					System.out.print("Pushing job");
					
				 	document.close();
				 	_o.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
				
			    System.out.println("Printing launched, please wait...");
			    
			} else {
				//forward request to other server ~
			}
		}
	}
%>

<%
    
	String why = request.getParameter("why");
    
    if(why != null && why.equals("UPDATE_CONFIG")) {
    	//JSONArray _config = new JSONArray(request.getParameter("config"));
    	//System.out.print(_config);
    	
    	//just write config to config file
    	ServletContext context = request.getServletContext();
    	String path = context.getRealPath("/");
    	System.out.println(path);
    	
    	PrintWriter writer = new PrintWriter(path + "config.txt", "UTF-8");
    	writer.println(request.getParameter("config"));
    	writer.close();
    	
    } else if(why != null && why.equals("REQUEST_PRINT")){
    	JSONArray params = new JSONArray(request.getParameter("params"));
    	//each JSONObject, find printer, print 
    	for(int i = 0; i < params.length(); i++) {
    		JSONObject item = params.getJSONObject(i);
    		String type = item.getString("type");
    		String sub_type = item.getString("sub_type");
    		
    		String doc_url = item.getString("doc_url");
    		String page_number_range = item.getString("page_number_range");
    		String count = item.getString("count");
    		
    		//print(type, sub_type, doc_url, page_number_range, count, request);
    	}
    	JSONObject obj = new JSONObject();
		out.print(obj);
    } else if(why != null && why.equals("REQUEST_CONFIG")) {
    	Config _config = new Config();
    	JSONArray config_json = _config.getJSONArray(request);
    	if(config_json == null) {
    		config_json = _config.getDefaultJSONArray(request);
    	}
    	
    	out.print(config_json);
    } else {
    	try {
    		MultipartParser m = new MultipartParser(request, 1000000000);
    		ArrayList<com.oreilly.servlet.multipart.Part> part_list = new ArrayList<>();
    		com.oreilly.servlet.multipart.Part p = null;
    		Map<String, byte[]> fileMap = new HashMap<>();
    		while((p = m.readNextPart()) != null) {
  				if(p.isParam()) {
    				part_list.add(((ParamPart)p));
  				}
  				
  				//it seems that if add FilePart to list, when fetch out, will not able to get file content
    			if(p.isFile()) {
    				FilePart pp = (FilePart)p;
    				part_list.add(pp);
    				
					ByteArrayOutputStream bos = new ByteArrayOutputStream();
	    			pp.writeTo(bos);
	    			fileMap.put(pp.getFileName(), bos.toByteArray());
	    			bos.close();
    			}
    		}
    		
    		PrintParameter printParam = null;
    		for(int i = 0; i < part_list.size(); i++) {
    			p = part_list.get(i);
    			if(p.getName().equals("why") &&
    					p.isParam() &&
    					((ParamPart)p).getStringValue().equals("REQUEST_PRINT")) {
    				printParam = new PrintParameter();
    				break;
    			}
    		}
    		
    		if(printParam != null) {
	    		for(int i = 0; i < part_list.size(); i++) {
	    			p = part_list.get(i);
	    			if(p.isParam()) {
	    				ParamPart pp = (ParamPart)p;
	    				if(pp.getName().equals("why")) {
	    					printParam.why = pp.getStringValue();
	    				}
	    				
	    				if(pp.getName().equals("params")) {
	    					printParam.loadFromParamJsonStr(pp.getStringValue());
	    				}
	    			}
	    			
	    			if(p.isFile()) {
	    				for(String fileName: fileMap.keySet()) {
    						printParam.loadFileToParam(fileName, fileMap.get(fileName));
	    				}
	    			}
	    		}
	    		
	    		printParam.dump();
	    		
	    		print(printParam, request);
    		}
    		
    	} catch(IOException e) {
    		
    	}
    }
%>