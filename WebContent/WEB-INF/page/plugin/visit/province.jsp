<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page pageEncoding="UTF-8" %> 
<%@ taglib prefix="ewcms" uri="/ewcms-tags"%>
<%@ taglib prefix="s" uri="/struts-tags" %>

<html>
	<head>
		<title>区域分布</title>	
		<s:include value="../../taglibs.jsp"/>
		<script type="text/javascript" src='<s:url value="/ewcmssource/page/visit/dateutil.js"/>'></script>
		<script type="text/javascript" src='<s:url value="/ewcmssource/fcf/js/FusionCharts.js"/>'></script>
		<script type="text/javascript">
			var startDate = dateTimeToString(new Date(new Date() - 30*24*60*60*1000));
			var endDate = dateTimeToString(new Date());
			$(function() {
				startDate = $('#startDate').val();
				endDate = $('#endDate').val();
				$('#tt').datagrid({
					singleSelect : true,
					pagination : false,
					nowrap : true,
					striped : true,
					url : '<s:url namespace="/plugin/visit" action="provinceTable"/>?startDate=' + $('#startDate').val() + '&endDate=' + $('#endDate').val() + '&country=' + $('#country').val(),
				    columns:[[  
				            {field:'province',title:'名称',width:120,
				            	formatter : function(val, rec){
				            		return '<a style="text-decoration: none" href="javascript:void(0);" onclick="openCity(\'' + val + '\')">' + val + '</a>';
				            	}},
				            {field:'pvRate',title:'PV比例',width:100},
				            {field:'pv',title:'PV数量',width:100},  
				            {field:'uv',title:'UV数量',width:100},
				            {field:'ip',title:'IP数量',width:100},
				            {field:'trend',title:'时间趋势',width:70,
				            	formatter : function(val, rec){	
				            		return '<a style="text-decoration: none" href="javascript:void(0)" onclick="openTrend(\'' + rec.province + '\')">时间趋势</a>';
				            	}
				            }
				    ]]  
				});
			});
			function showChart(){
				var parameter = {};
				parameter['startDate'] = startDate;
				parameter['endDate'] = endDate;
				parameter['country'] = $('#country').val();
				$.post('<s:url namespace="/plugin/visit" action="provinceReport"/>', parameter, function(result) {
			  		var myChart = new FusionCharts('<s:url value="/ewcmssource/fcf/swf/Pie3D.swf"/>?ChartNoDataText=无数据显示', 'myChartId', '640', '250','0','0');
		      		myChart.setDataXML(result);      
		      		myChart.render("divChart");
		   		});
			}
			function refresh(){
				startDate = $('#startDate').val();
				endDate = $('#endDate').val();
				showChart();
				$('#tt').datagrid({
					url:'<s:url namespace="/plugin/visit" action="provinceTable"/>?startDate=' + $('#startDate').val() + '&endDate=' + $('#endDate').val() + '&country=' + $('#country').val()
				})
			}
			function openTrend(value){
				ewcmsBOBJ = new EwcmsBase();
				var url = '<s:url namespace="/plugin/visit" action="provinceTrend"/>?startDate=' + $('#startDate').val() + '&endDate=' + $('#endDate').val() + '&country=' + $('#country').val() + '&province=' + value;
				ewcmsBOBJ.openWindow("#pop-window",{url:url,width:660,height:330,title: $('#country').val() + " >> " + value + " 时间趋势"});
			}
			function openCity(name){
				window.location = '<s:url namespace="/plugin/visit" action="city"/>?country=' + $('#country').val() + '&province=' + name + '&startDate=' + $('#startDate').val() + '&endDate=' + $('#endDate').val(); 
			}
		</script>
		<ewcms:datepickerhead></ewcms:datepickerhead>
	</head>
	<body class="easyui-layout">
		 <s:hidden name="country" id="country"/>
		 <div region="north" style="height:310px">
			<table width="100%" border="0" cellspacing="6" cellpadding="0"style="border-collapse: separate; border-spacing: 6px;">
				<tr>
					<td>
						当前报表：<a style="text-decoration: none" href="<s:url namespace='/plugin/visit' action='country'/>?startDate=<s:property value='%{startDate}'/>&endDate=<s:property value='%{endDate}'/>">全部</a> >> <font color="red"><s:property value='%{country}'/></font> 区域分布
					</td>
				</tr>
				<tr>
					<td>
						从 <ewcms:datepicker id="startDate" name="startDate" option="inputsimple" format="yyyy-MM-dd"/> 至 <ewcms:datepicker id="endDate" name="endDate" option="inputsimple" format="yyyy-MM-dd"/> <a class="easyui-linkbutton" href="javascript:void(0)" onclick="refresh();return false;">查看</a>
					</td>
				</tr>
				<tr valign="top">
					<td>
					<table width="100%" border="0" cellspacing="0" cellpadding="0" class="blockTable">
						<tr>
							<td style="padding:0px;">
								<div style="height: 100%;margin:0px;">
									<div id="divChart" style="width:640px;height:250px;background-color:white"></div>
									<script type="text/javascript">
										showChart();
									</script>
								</div>
							</td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
		</div>
		<div region="center">
			<table id="tt" fit="true"></table>
		</div>
		<div id="pop-window" class="easyui-window" title="弹出窗口" icon="icon-visit-analysis" closed="true" style="display:none;">
            <div class="easyui-layout" fit="true">
                <div region="center" border="false">
                	<iframe id="editifr_pop"  name="editifr_pop" class="editifr" frameborder="0" width="100%" height="100%" scrolling="no"></iframe>
                </div>
            </div>
        </div>
	</body>
</html>