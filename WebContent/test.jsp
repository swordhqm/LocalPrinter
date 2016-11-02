<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%-- Set the content disposition header --%>
<%@ page import="javax.print.*"%>
<%@ page import="javax.print.attribute.*"%>
<%@ page import="javax.print.attribute.standard.*"%>
<%@ page import="java.io.*"%>
<%@ page import="org.apache.pdfbox.pdmodel.*"%>
<%@ page import="org.apache.pdfbox.printing.*"%>
<%@ page import="org.json.*" %>
<%@ page import="java.util.*" %>

<html>
<head>
<style type="text/css">
body {
	margin-top: 5px;
	margin-left: 5px;
	margin-right: 5px;
	margin-bottom: 5px;
}

textarea {
	width: 100%;
}
</style>
<title>My_Printer</title>
<script type="text/javascript"
	src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
</head>

<body link="#009900" vlink="#009900" TEXT="#4b73af">
	<!--This section is for message display on browser page -->
	<table id="config_table" border="0" width="100%">
		<tr width="100%">
			<td width="100%">
				<div id="title" align="center">打印机 配置</div>
			</td>
		</tr>
		<tr>
			<td width="100%">
				<div id="Label" align="center">
					Label printer(4X2): <input type="text" placeholder="localhost" />
					Printer name:<input type="text">
				</div>
			</td>
		</tr>
		<tr>
			<td width="100%">
				<div id="Location" align="center">
					Local printer: <input type="text" placeholder="localhost" />
					Printer name:<input type="text">
				</div>
			</td>
		</tr>
		<tr>
			<td width="100%">
				<div id="Fnsku" align="center">
					Fnsku printer: <input type="text" placeholder="localhost" />
					Printer name:<input type="text">
				</div>
			</td>
		</tr>
	</table>
	<div align="center">
		<input type="button" value="save" onclick="save()" />
	</div>
	<!-- end message display -->

	<script type="text/javascript">
		var config = [];
		
		var config_table = {
			init: function(){
				
			},
			refresh: function() {
				$('#config_table tr').remove();
				for(var i in config) {
					_c = config[i];
					content = [
						'<tr>',
							'<td width="100%">',
								'<div id="' + _c['description'] + '" align="center">',
									_c['description'] + '('+ _c['pageType'] +')' + ': <input type="text" placeholder="localhost" />',
									'Printer Name: <input type="text" placeholder="'+ _c['printer_name'] +'">',
								'</div>',
							'</td>',
						'</tr>',
					];
					$('#config_table').append(content.join(""));
				}
			}
		};
		
		function reloadConfigfromRemote() {
			//request from remote, which define a list of what kind of pdf need to be print out
			//write response to local webserver config
		}
		
		function save() {
			/*
			config[0] = {
				"type": "Location",
				"sub_type": "t1(4x2)",
				"position": "localhost",
				"printer_name": "ZDesigner LP 2844",
				"description": "打印location",
				"pageType": "4x2",
			};*/
			$('#config_table tr').each(function(index, element){
				_cf = config[index];
				$(element).find("input[type=text]").each(function(index, element){
					if(index == 0) { //address
						_cf['position'] = $(element).val()? $(element).val():$(element).attr("placeholder");
					} else if(index == 1) {	//printer name
						_cf['printer_name'] = $(element).val()? $(element).val():$(element).attr("placeholder");
					}
				});
			});
			$.ajax({
				type: "POST",
				url: "service.jsp",
				data: {
					"why": "UPDATE_CONFIG",
					"config": JSON.stringify(config),
				},
				dataType: "json",
				success: function(msg) {
					
				},
				error: function(msg) {
					
				}
			});
		}
		
		function load() {
			$.ajax({
				type:"POST",
				url:"service.jsp",
				data: {
					"why": "REQUEST_CONFIG",
				},
				dataType: "json",
				success: function(msg) {
					config = msg;
					config_table.refresh();
					console.log(msg)
				},
				error: function(msg) {
					
				}
			});
		}
		
		function test() {
			var blob = new Blob(["xxxxxxxxxxxxxxxxxxxxxxxxx"], {type: 'text/plain'});
			//var fileURL = URL.createObjectURL(file);
			var formData = new FormData();
			
			formData.append("why", "REQUEST_PRINT");
			params = [{
				"type": "Location",
    			"sub_type": "t1(4x2)",
    			"file_name": "xx.txt",
    			"page_number_range": "all",
    			"count": "2"
			}];
			formData.append("params", JSON.stringify(params));
			formData.append("file", blob, "xx.txt"); //file one by one
			
			var request = new XMLHttpRequest();
			request.open("POST", "service.jsp");
			request.send(formData);
			return;
			
			/*
			$.ajax({
				type: "POST",
				url: "service.jsp",
				data: {
					"why": "REQUEST_PRINT",
					"params": JSON.stringify(params),
				},
				dataType: "json",
				success: function(msg) {
					console.log(msg);
				},
				error: function(msg) {
					console.log(msg)
				}
			});*/
		}
		
		$(document).ready(function(){
			load();
		});
	</script>

</body>
</html>
