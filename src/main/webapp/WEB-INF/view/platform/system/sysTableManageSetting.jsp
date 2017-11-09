<%--
	time:2012-06-25 11:05:09
	desc:edit the 通用表单对话框
--%>
<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/commons/include/html_doctype.html"%>
<html>
<head>
	<title>编辑 自定义表管理设置</title>
	<%@include file="/commons/include/get.jsp" %>		
	<script type="text/javascript"src="${ctx}/js/cosim/platform/system/ScriptDialog.js"></script>
	<script type="text/javascript">
		//是否是树结构
		var isTree=${style==1 };
		$(function() {
				$("#defLayout").ligerLayout({ leftWidth: 270,height: '100%',
				bottomHeight:50,allowLeftCollapse:false,rightWidth:465,allowRightResize:false,centerWidth:20,
			 	allowBottomResize:false,allowRightCollapse:false});
				init();	
		});
		//初始化页面
		function init(){
			$("input.treeField").focus(function(){
				curField=$(this);
			});
// 			if(isTree){
// 				resultCheck();
// 			}
			var fields = window.dialogArguments;	
			if(fields.displayField)initDisplayField(fields.displayField);
			if(fields.conditionField)initConditionField(fields.conditionField);
// 			if(fields.resultField)initResultField(fields.resultField);
		}
		//未保存自定义表管理的，在已经设置列以后再次打开设置列的窗口时 初始化已设置的显示列
		function initDisplayField(displayField){
			var fieldObj=eval("("+displayField+")"),
				objContainer=$("#trDisplayField");
			objContainer.empty();
			if(!isTree){
				for(var i=0,c;c=fieldObj[i++];){
					objContainer.append(getDispalyField(c.fieldName,c.comment,c.fieldType));
				}
			}
			else{
				if(fieldObj.id)$("#treeId").val(fieldObj.id);
				if(fieldObj.pid)$("#parentId").val(fieldObj.pid);
				if(fieldObj.displayName)$("#displayName").val(fieldObj.displayName);
			}
		};
		//初始化条件列
		function initConditionField(conditionField){
			var fieldObj=eval("("+conditionField+")"),
				objContainer=$("#trConditionField");
			objContainer.empty();
			for(var i=0,c;c=fieldObj[i++];){
				objContainer.append(getConditionField(c.fieldName,c.comment,c.fieldType,!isTree));
				var curTr = $("#condition"+c.fieldName),
					curValTr = $("#conditionVal"+c.fieldName);
				$("select.condition",curTr).val(c.condition);
				$("select[name='changeValueFrom']",curValTr).val(c.valueFrom);
				changeValueFrom($("select[name='changeValueFrom']",curValTr));
				$("textarea[name='value']",curValTr).val(c.value);
			}
		};
		
		var curField;
		
// 		function resultCheck(){
// 			var id=$("#id").val();			
// 			if(id<1) return;
// 			var returnField=$("#resultfield").val();
// 			$("input:checkbox[name='treeReturn']:checked").each(function(){
// 				$(this).removeAttr("checked");
// 			});
// 			var aryField=returnField.split(",");
// 			for(var i=0;i<aryField.length;i++){
// 				$("input:text[value='"+aryField[i]+"']").next().attr("checked","checked");
// 			}
				
// 		}
		
		function selectTreeField(){   //左边字段选择
			var obj=$("input:radio[name='fieldName']:checked");
			if(curField==null || curField.length==0){
				$.ligerMessageBox.error('提示信息',"请选择右边的输入框!");
				return;
			}
			if(obj.length==0){
				$.ligerMessageBox.error('提示信息',"请选择左边的字段!");
				return;
			}
			
			if(obj.length>0){
				curField.val(obj.val());
			}
		}
		
		function setDisplayField(){
			var objContainer=$("#trDisplayField");
			$("input:checkbox[name='fieldName']:checked").each(function(){
				var trObj=$(this).closest("tr");	
				var fieldName=$(this).val();  //id
				var comment=$("input[name='comment']",trObj).val();
				var fieldType=$(this).attr("dbType");
				var obj=$("#display" + fieldName);
				if(obj.length==0){
					var tr=getDispalyField(fieldName,comment,fieldType);
					objContainer.append(tr);
				}
			});
		}
		//删除表中的一行
		function delRow(obj){
			$(obj).closest("tr").remove();
			
		}
		//删除条件列的表中的一行
		function delConditionTr(obj){
			var tr=$(obj).closest("tr");
			tr.next().remove().end().remove();
		}
		//动态构造显示列的表中的一行
		function getDispalyField(fieldName,comment,fieldType){
			var sb=new StringBuffer();
			sb.append("<tr id='display"+ fieldName +"' name='"+fieldName+"' comment='"+comment+"' dbType='"+fieldType+"' >");
			sb.append("<td >"+fieldName+"</td>");
			sb.append("<td >"+comment+"</td>");
			sb.append("<td><a alt='上移' href='#' class='link moveup' onclick='sortUp(this)'>&nbsp;&nbsp;</a>");
			sb.append("<a alt='下移' href='#' class='link movedown' onclick='sortDown(this)'>&nbsp;&nbsp;</a>");
			sb.append("<a href='#' class='link del'  onclick='delRow(this)' >删除</a></td>");
			sb.append("</tr>");
			return sb.toString();
		}
		//动态构造条件列的表中的一行
		function getConditionField(fieldName,comment,dbType,isList){
			var db=getConditionSelect(dbType,fieldName,comment);
			var sb=new StringBuffer();
			sb.append("<tr class='trCondition' id='condition"+ fieldName +"'>");
			sb.append("<td >"+fieldName+"</td>");
			sb.append("<td >"+db+"</td>");
			sb.append("<td >"+comment+"</td>");
			sb.append("<td><a alt='上移' href='#' class='link moveup' onclick='sortConditionTr(this,true)'></a>");
			sb.append("<a alt='下移' href='#' class='link movedown' onclick='sortConditionTr(this,false)'></a>");
			sb.append("<a href='#' class='link del'  onclick='delConditionTr(this)' >删除</a></td>");
			sb.append("</tr>");
			sb.append("<tr id='conditionVal"+ fieldName +"'>");
			sb.append("<td>值来源</td>");
			sb.append("<td><select name='changeValueFrom' onchange='changeValueFrom(this)'>");
			if(isList){
				sb.append("<option value='1'>表单输入</option>");
			}
			sb.append("<option value='2'>固定值</option><option value='3'>脚本</option></select></td>");
			sb.append("<td colspan='2'><a style='display:none;' href='#' name='btnScript' class='link var' title='常用脚本' onclick='selectScript(this)'>常用脚本</a>");
			sb.append("<textarea name='value' cols='40' rows='3' ");
			if(isList){
				sb.append("		style='display:none;' ");	
			}
			sb.append("></textarea></td>");
			sb.append("</tr>");
			return sb.toString();
		}
		//选择脚本
		function selectScript(obj) {
			var linkObj=$(obj);
			var txtObj=linkObj.next()[0];
			ScriptDialog({
				callback : function(script) {
					$.insertText(txtObj,script);
				}
			});
		};
		//修改值来源
		function changeValueFrom(obj){
			var val=$(obj).val();
			var objTr=$(obj).parents("tr");
			var txtObj=$("textarea[name='value']",objTr);
			var linkObj=$("a[name='btnScript']",objTr);
			switch(val){
				case "1":
					txtObj.hide();
					linkObj.hide();
					break;
				case "2":
					txtObj.show();
					linkObj.hide();
					break;
				case "3":
					txtObj.show();
					linkObj.show();
					break;
			}
		}
		//动态构造Select元素
		function getConditionSelect(dbType,name,comment){
			var sb=new StringBuffer();
			sb.append("<select class='condition' name='"+name+"' dbType='"+dbType+"' comment='"+comment+"'>");
			switch(dbType){
				case "varchar":
					sb.append("<option value='='>等于</option>");
					sb.append("<option value='like'>LIKE</option>");
					sb.append("<option value='likeEnd'>LIKEEND</option>");
					break;
				case "number":
					sb.append("<option value='='>等于</option>");
					sb.append("<option value='>='>大于等于</option>");
					sb.append("<option value='>'>大于</option>");
					sb.append("<option value='<'>小于</option>");
					sb.append("<option value='<='>小于等于</option>");
					break;
				case "date":
					sb.append("<option value='='>等于</option>");
					sb.append("<option value='between'>Between</option>");
					sb.append("<option value='>='>大于等于</option>");
					sb.append("<option value='<='>小于等于</option>");
					
					break;
				
			}
			
			sb.append("</select>");
			return sb;
		}
		
		//将左边选中的列添加到右边的条件列中
		function setConditionField(isList){
			var objContainer=$("#trConditionField");
			$("input[name='fieldName']:checked").each(function(){
				var trObj=$(this).closest("tr");	
				var fieldName=$(this).val();  //id
				var comment=$("input[name='comment']",trObj).val();
				var dbType=$(this).attr("dbType");
				var tr=getConditionField(fieldName,comment,dbType,isList);
				objContainer.append(tr);
				
			});
		}
		
		//显示列的Json Stringify
		var displayStr="";
		//条件列的Json Stringify
		var conditionStr="";
		var rtnStr="";
		
		function buildTreeJson(){
			var  rtn="";
			var treeId=$("#treeId").val();
			var parentId=$("#parentId").val();
			var displayName=$("#displayName").val();
			
			if(treeId=="" || parentId=="" || displayName==""){
				rtn+="请填写映射树的字段\r\n";
			}

			var display={
				id:treeId,
				pid:parentId,
				displayName:displayName
			};
			displayStr=JSON.stringify(display);
// 			$("input:checkbox[name='treeReturn']:checked").each(function(){
// 				var prevObj=$(this).prev();   
// 				rtnStr+=prevObj.val()+",";
// 			});
			
			var result=getCondition();
			
			if(!result){
				rtn+="请填写条件字段的值\r\n";
			}
			return rtn;
			
		}
		
		//获取选择的条件。
		function getCondition(){
			var aryContion=[];
			var rtn=true;
			$("#trConditionField").children("tr.trCondition").each(function(){
				var trObj=$(this);
				var trDefault=trObj.next();
				var selObj=$('select.condition',trObj);
				var fieldName=selObj.attr("name");
				var comment=selObj.attr("comment");
				var condition=selObj.attr("value");
				var fieldType=selObj.attr("dbType");
				var obj={};
				obj.fieldName=fieldName;
				obj.comment=comment;
				obj.condition=condition;
				obj.fieldType=fieldType;
				
				var selDefault=$("select[name='changeValueFrom']",trDefault).val();
				var txtDefault=$("textarea[name='value']",trDefault).val();
				if(selDefault!="1" && txtDefault.trim()==""){
					rtn=false;
				}
				obj.valueFrom=selDefault;
				if(selDefault=="1"){
					obj.value="";
				}
				else{
					obj.value=txtDefault;
				}
				aryContion.push(obj);
			});
			conditionStr=JSON.stringify(aryContion);
			return rtn;
		}
		
		//显示类型为列表，取得列设置信息
		function buildListJson(){
			var rtn="";
			var aryDisplay=[];
			$("#trDisplayField").children().each(function(){
				var fieldName=$(this).attr("name");
				var comment=$(this).attr("comment");
				var fieldType=$(this).attr("dbType");
				var obj={};
				obj.fieldName=fieldName;
				obj.comment=comment;
				obj.fieldType=fieldType;
				aryDisplay.push(obj);
			});
			if(aryDisplay.length==0){
				rtn="请选择显示字段\r\n";
			}
			var result=getCondition();
			if(!result){
				rtn+="请填写条件字段的值\r\n";
			}
			displayStr=JSON.stringify(aryDisplay);
			return rtn;
		}
		
		//取得列设置
	    function selectForm(){
	    	var rtn="";
			//如果是树状的只取不大于3个的返回值				
			if($("input.treeField").length>0) {
				rtn=buildTreeJson();
			}
			else{
				rtn=buildListJson();
			}
			if(rtn!=""){
				$.ligerMessageBox.warn('提示信息',rtn);
				return;
			}
			var rerurnlist= new Array(displayStr,conditionStr); 
			window.returnValue=rerurnlist;
	    	window.close();
	    }
	    
		function sortTr(obj,isUp) {
			var thisTr = $(obj).parents("tr");
			if(isUp){
				var prevTr = $(thisTr).prev();
				if(prevTr){
					thisTr.insertBefore(prevTr);
				}
			}
			else{
				var nextTr = $(thisTr).next();
				if(nextTr){
					thisTr.insertAfter(nextTr);
				}
			}
		};
	    
		function sortConditionTr(obj,isUp) {
			var thisTr = $(obj).closest("tr");
			var nextTr=thisTr.next();
			
			//向上
			if(isUp){
				var prevTr = thisTr.prev();
				if(prevTr.length==0) return;
				var targeTr=prevTr.prev();
				thisTr.insertBefore(targeTr)
				nextTr.insertBefore(targeTr);
			}
			else{
				var tmpTr =nextTr.next();
				if(tmpTr.length==0) return;
				var targeTr=tmpTr.next();
				nextTr.insertAfter(targeTr);
				thisTr.insertAfter(targeTr);
			}
		};
	
	    
	</script>
	<style type="text/css">
		body{ padding:2px; margin:0 0 0 0;overflow: hidden; }
		div.fieldContainer{border:1px solid #BED5F3;margin-top: 3px;height:215px;}
		div.content{height:180px;overflow: auto;}
		ul.btnContainer{text-align: center;margin-top: 60px;}
		li.btn{margin-top: 3px;height:215px;line-height:143px; }
		li.btnTree{margin-top: 3px;height:40px;line-height:40px; }
	</style>
	
</head>
<body>
		<div id="defLayout" >
	            <div position="left" title="获取字段列表" style="overflow: auto;width: 300px;height:450px;">
					<table cellpadding="1" class="table-grid table-list" cellspacing="1">
						<tr>
							<th></th>
							<th>字段</th>
							<th>注释</th>
						</tr>
						<c:forEach var="col" items="${tableModel.columnList }" varStatus="status">
						<c:set var="clsName"  ><c:choose><c:when test="${status.index%2==0}">odd</c:when><c:otherwise>even</c:otherwise></c:choose> </c:set>
						<tr class="${clsName}">
							<td>
								<c:choose>
	            					<c:when test="${style==0 }">
										<input type="checkbox" name="fieldName"  class="pk"  value="${col.name }"  dbType="${col.columnType }">
									</c:when>
									<c:otherwise>
										<input type="radio" name="fieldName" class="pk"  value="${col.name }" id="${col.name }" dbType="${col.columnType }">
									</c:otherwise>
								</c:choose>
							</td>
							<td nowrap="nowrap">
								${col.name }
							</td>
							<td>
								<input type="text" name="comment" class="inputText" value="${col.comment }">
							</td>
						</tr>
						</c:forEach>
					</table>
	            </div>
	            <div position="center" >
	            	<c:choose>
	            		<c:when test="${style==0 }">
	            			<ul class="btnContainer">
			          			<li class="btn">
			          				 <a href='#' class='button'  onclick="setDisplayField()" ><span >=></span></a>
			          			</li>
			          			<li class="btn">
			          				<a href='#' class='button'  onclick="setConditionField(true)" ><span >=></span></a>
			          			</li>
			          		</ul>
	            		</c:when>
	            		<c:otherwise>
	            			<ul class="btnContainer">
			          			<li class="btnTree">
			          				 <a href='#' class='button'  onclick="selectTreeField()" ><span >==></span></a>
			          			</li>
			          			
			          			<li class="btnTree" style="margin-top:120px;">
			          				 <a href='#' class='button'  onclick="setConditionField(false)" ><span >==></span></a>
			          			</li>
			          		</ul>
	            		</c:otherwise>
	            	</c:choose>
	            	
	          		
	            </div>  
	            <div id="fieldSetting" position="right"  title="字段设置">
	            	<c:choose>
	            		<c:when test="${style==0 }">
			          		<div class="fieldContainer">
			          			<div class="header">
			          				显示的字段
			          			</div>
			          			<div class="content">
			          				<table cellpadding="1" class="table-grid table-list" cellspacing="1">
				          				<tr>
				          					<th>
				          						字段名
				          					</th>
				          					<th>
				          						显示名
				          					</th>
				          					<th>
				          						管理
				          					</th>
				          				</tr>
				          				<tbody id="trDisplayField">
				          					<c:forEach items="${ sysTableManage.displayList}" var="field">
				          						<tr id='display${field.fieldName}' name='${field.fieldName}' comment='${field.comment}' dbType="${field.fieldType}">
				          							<td>${field.fieldName}</td>
				          							<td>${field.comment}</td>
				          							<td>
				          							<a alt='上移' href='#' class='link moveup' onclick='sortTr(this,true)'>&nbsp;</a>
				          							<a alt='下移' href='#' class='link movedown' onclick='sortTr(this,false)'>&nbsp;</a>
				          							<a href='#' class='link del'  onclick='delRow(this)' >删除</a>
				          							</td>
				          						</tr>
				          					</c:forEach>
				          				</tbody>
				          			</table>
			          			</div>
			          			
			          		</div>
			          		<div class="fieldContainer">
			          			<div class="header">
			          				条件字段
			          			</div>
			          			<div class="content">
				          			<table cellpadding="1" class="table-grid table-list" cellspacing="1">
				          				<tr>
				          					<th>
				          						字段名
				          					</th>
				          					<th>
				          						条件
				          					</th>
				          					
				          					<th>
				          						显示名
				          					</th>
				          					<th>
				          						管理
				          					</th>
				          				</tr>
				          				<tbody id="trConditionField">
				          					<c:forEach items="${ sysTableManage.conditionList}" var="field">
				          						<tr class='trCondition' id='condition${field.fieldName}' name='${field.fieldName}' comment='${field.comment}'>
				          							<td>${field.fieldName}</td>
				          							<td>
				          								<select class='condition' name='${field.fieldName}' dbType='${field.fieldType}' comment='${field.comment}' >
					          								<c:choose>
					          									<c:when test="${field.fieldType=='varchar'}">
						          									<option value='=' <c:if test="${field.condition=='='}">selected</c:if> >等于</option>
																	<option value='like' <c:if test="${field.condition=='like'}">selected</c:if>>LIKE</option>
																	<option value='likeEnd' <c:if test="${field.condition=='likeEnd'}">selected</c:if>>LIKEEND</option>
					          									</c:when>
					          									<c:when test="${field.fieldType=='number'}">
					          										<option value='=' <c:if test="${field.condition=='='}">selected</c:if>>等于</option>
																	<option value='>=' <c:if test="${field.condition=='>='}">selected</c:if> >大于等于</option>
																	<option value='>' <c:if test="${field.condition=='>'}">selected</c:if> >大于</option>
																	<option value='<' <c:if test="${field.condition=='<'}">selected</c:if> >小于</option>
																	<option value='<=' <c:if test="${field.condition=='<='}">selected</c:if>>小于等于</option>
					          									</c:when>
					          									<c:otherwise>
					          										<option value='=' <c:if test="${field.condition=='='}">selected</c:if>>等于</option>
					          										<option value='between' <c:if test="${field.condition=='between'}">selected</c:if> >between</option>
																	<option value='>=' <c:if test="${field.condition=='>='}">selected</c:if> >大于等于</option>
																	<option value='<=' <c:if test="${field.condition=='<='}">selected</c:if> >小于等于</option>
					          									</c:otherwise>
					          								</c:choose>
				          								</select>
													</td>
													<td>${field.comment}</td>
				          							
				          							<td>
				          							<a alt='上移' href='#' class='link moveup' onclick='sortConditionTr(this,true)'></a>
				          							<a alt='下移' href='#' class='link movedown' onclick='sortConditionTr(this,false)'></a>
				          							<a href='#' class='link del'  onclick='delConditionTr(this)' >删除</a>
				          							</td>
				          						</tr>
				          					
			
				          						<tr id='conditionVal${field.fieldName}'>
				          							<td>值来源</td>
				          							<td>
				          								<select name='changeValueFrom' onchange='changeValueFrom(this)'>
				          									<option value="1" <c:if test="${field.valueFrom=='1'}">selected</c:if>>表单输入</option>
				          									<option value="2" <c:if test="${field.valueFrom=='2'}">selected</c:if>>固定值</option>
				          									<option value="3" <c:if test="${field.valueFrom=='3'}">selected</c:if>>脚本</option>
				          								</select>
				          							</td>
				          							<td colspan="2">
				          							<a <c:if test="${field.valueFrom=='1' || field.valueFrom=='2'}">style='display:none;'</c:if>  href='#' name='btnScript' 
				          							class='link var' title='常用脚本' onclick='selectScript(this)'>常用脚本</a>
				          							<textarea name='value' cols='40' rows='3' 
				          							<c:if test="${field.valueFrom=='1' }">style='display:none;'</c:if>>${field.value}</textarea></td>
				          						</tr>
				          					</c:forEach>
				          				</tbody>
				          			</table>
			          			</div>
			          		</div>
			          	</c:when>
			          	<c:otherwise>
			          	<div class="panel-detail">
			          		<table class="table-detail" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<th width="20%">ID: </th>
									<td>
										<input type="text" id="treeId"  name="treeId"  class="inputText treeField" value="${ sysTableManage.treeField.id}"/>								
<!-- 										<input type="checkbox" name="treeReturn" checked="checked" />返回 -->
									</td>
								</tr>
								<tr>
									<th width="20%">父ID: </th>
									<td><input type="text" id="parentId" name="parentId"  class="inputText treeField" value="${ sysTableManage.treeField.pid}"/>
<!-- 										<input type="checkbox" name="treeReturn"/>返回 -->
									</td>
								</tr>
								<tr>
									<th width="20%">显示名称: </th>
									<td>
										<input type="text" id="displayName" name="displayName"  class="inputText treeField" value="${sysTableManage.treeField.displayName}"/>
<!-- 										<input type="checkbox" name="treeReturn" checked="checked" />返回 -->
										
									</td>
								</tr>
								
							</table>
							</div>
							
		          			<div class="header" style="margin-top:5px;">
		          				条件字段
		          			</div>
		          			<div class="content" style="height:220px;">
			          			<table cellpadding="1" class="table-grid table-list" cellspacing="1">
			          				<tr>
			          					<th>
			          						字段名
			          					</th>
			          					<th>
			          						条件
			          					</th>
			          					
			          					<th>
			          						显示名
			          					</th>
			          					<th>
			          						管理
			          					</th>
			          				</tr>
			          				<tbody id="trConditionField">
			          					<c:forEach items="${ sysTableManage.conditionList}" var="field">
			          						<tr class='trCondition' id='condition${field.fieldName}' name='${field.fieldName}' comment='${field.comment}'>
			          							<td>${field.fieldName}</td>
			          							<td>
			          								<select class='condition' name='${field.fieldName}' dbType='${field.fieldType}' comment='${field.comment}' >
			          								<c:choose>
			          									<c:when test="${field.fieldType=='varchar'}">
				          									<option value='=' <c:if test="${field.condition=='='}">selected</c:if> >等于</option>
															<option value='like' <c:if test="${field.condition=='like'}">selected</c:if>>LIKE</option>
															<option value='likeEnd' <c:if test="${field.condition=='likeEnd'}">selected</c:if>>LIKEEND</option>
			          									</c:when>
			          									<c:when test="${field.fieldType=='number'}">
			          										<option value='=' <c:if test="${field.condition=='='}">selected</c:if>>等于</option>
															<option value='>=' <c:if test="${field.condition=='>='}">selected</c:if> >大于等于</option>
															<option value='>' <c:if test="${field.condition=='>'}">selected</c:if> >大于</option>
															<option value='<' <c:if test="${field.condition=='<'}">selected</c:if> >小于</option>
															<option value='<=' <c:if test="${field.condition=='<='}">selected</c:if>>小于等于</option>
			          									</c:when>
			          									<c:otherwise>
			          										<option value='=' <c:if test="${field.condition=='='}">selected</c:if>>等于</option>
															<option value='between' <c:if test="${field.condition=='between'}">selected</c:if> >between</option>
															<option value='>=' <c:if test="${field.condition=='>='}">selected</c:if> >大于等于</option>
															<option value='<=' <c:if test="${field.condition=='<='}">selected</c:if> >小于等于</option>
			          									</c:otherwise>
			          								</c:choose>
			          								</select>
												</td>
												<td>${field.comment}</td>
			          							
			          							<td>
			          							<a alt='上移' href='#' class='link moveup' onclick='sortConditionTr(this,true)'></a>
			          							<a alt='下移' href='#' class='link movedown' onclick='sortConditionTr(this,false)'></a>
			          							<a href='#' class='link del'  onclick='delConditionTr(this)' >删除</a>
			          							</td>
			          						</tr>
			          					
		
			          						<tr id='conditionVal${field.fieldName}'>
			          							<td>值来源</td>
			          							<td>
			          								<select name='changeValueFrom' onchange='changeValueFrom(this)'>
			          									<option value="2" <c:if test="${field.valueFrom=='2'}">selected</c:if>>固定值</option>
			          									<option value="3" <c:if test="${field.valueFrom=='3'}">selected</c:if>>脚本</option>
			          								</select>
			          							</td>
			          							<td colspan="2">
			          							<a <c:if test="${ field.valueFrom=='2'}">style='display:none;'</c:if>  href='#' name='btnScript' 
			          							class='link var' title='常用脚本' onclick='selectScript(this)'>常用脚本</a>
			          							<textarea name='valueFrom' cols='40' rows='3' >${field.valueFrom}</textarea></td>
			          						</tr>
			          					</c:forEach>
			          				</tbody>
			          			</table>
		          			</div>
			          		
							
			          	</c:otherwise>
			          </c:choose>
	            </div>
	            <div position="bottom" class="bottom" style="padding-top: 15px;">
					  <a href='#' class='button'  onclick="selectForm()" ><span class="icon ok"></span><span >确定</span></a>
			  		<a href='#' class='button' style='margin-left:10px;' onclick="window.close()"><span class="icon cancel"></span><span >取消</span></a>
				</div>
				
<%-- 				<input type="hidden" name="resultfield" id="resultfield" value="${sysTableManage.resultfield}"/> --%>
				<input type="hidden" name="id" id="id" value="${sysTableManage.id}"/>
       	  </div>
       	 
</body>
</html>
