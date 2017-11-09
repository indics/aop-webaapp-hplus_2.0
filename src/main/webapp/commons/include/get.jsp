<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="f" uri="http://www.jee-soft.cn/functions" %>
<%@ taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@ taglib prefix="cosim" uri="http://www.jee-soft.cn/paging" %>
<%@ taglib prefix="ap" uri="/appleTag"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
<f:link href="Aqua/css/ligerui-all.css"></f:link>
<f:link href="web.css"></f:link>
<script type="text/javascript" src="${ctx}/js/dynamic.jsp"></script>
<script type="text/javascript" src="${ctx}/js/jquery/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="${ctx}/js/util/util.js"></script>
<script type="text/javascript" src="${ctx}/js/layer/layer.js"></script>
<script type="text/javascript" src="${ctx}/js/util/form.js"></script>
<script type="text/javascript" src="${ctx}/js/lg/ligerui.min.js"></script>
<script type="text/javascript" src="${ctx}/js/cosim/displaytag.js" ></script>
<script type="text/javascript" src="${ctx}/js/lg/plugins/ligerDialog.js" ></script>
<script type="text/javascript" src="${ctx}/js/calendar/My97DatePicker/WdatePicker.js"></script>
<%@include file="/js/msg.jsp"%>