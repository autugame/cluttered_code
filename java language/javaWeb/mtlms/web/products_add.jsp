<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="renderer" content="webkit|ie-comp|ie-stand">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta http-equiv="Cache-Control" content="no-siteapp" />
    <link href="assets/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="css/style.css"/>
    <link href="assets/css/codemirror.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/ace.min.css" />
    <link rel="stylesheet" href="font/css/font-awesome.min.css" />
    <!--[if lte IE 8]>
    <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
    <![endif]-->
    <script src="js/jquery-1.9.1.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/typeahead-bs2.min.js"></script>
    <script src="assets/js/jquery.dataTables.min.js"></script>
    <script src="assets/js/jquery.dataTables.bootstrap.js"></script>
    <script src="assets/layer/layer.js" type="text/javascript" ></script>
    <script src="assets/laydate/laydate.js" type="text/javascript"></script>
    <script src="js/dragDivResize.js" type="text/javascript"></script>
    <title>添加商品</title>
</head>

<body>
<form action="GoodsAddServlet" method="post">
<div class="Competence_add_style clearfix">
    <div class="left_Competence_add">
        <div class="title_name">添加商品</div>
        <div class="Competence_add">
            <div class="form-group">
                <label class="col-sm-3 control-label no-padding-right"> 一级分类 </label>
                <div class="col-sm-9">
                    <select id="categorySelect" name="" class="col-xs-10 col-sm-10">
                        <option value=''>请选择商品分类</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-3 control-label no-padding-right"> 商品品牌 </label>
                <div class="col-sm-9">
                    <select id="brandSelect" name="brandId" class="col-xs-10 col-sm-10">
                        <option value=''>请选择商品品牌</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="col-sm-3 control-label no-padding-right" for="form-field-3"> 商品名称 </label>
                <div class="col-sm-9"><input type="text" id="form-field-3" name="goodsName" placeholder="商品名称" class="col-xs-10 col-sm-10"></div>
            </div>

            <div class="form-group"><label class="col-sm-3 control-label no-padding-right" for="form-field-4"> 商品图片 </label>
                <div class="col-sm-9">
                    <img src="" id="reviewImg" height="80"/>
                    <hr/>
                    <input type="hidden" id="goodsImgPath" name="goodsImgPath"/>
                    <input type="file" id="form-field-4" class="col-xs-10 col-sm-10" onchange="uploadImg()">
                </div>
            </div>
            <script type="text/javascript">
                function uploadImg(){
                    var file = $("#form-field-4")[0].files[0];
                    var formData = new FormData();
                    formData.append("brandLogoImg", file);
                    $.ajax({
                        type:"post",
                        url:"ImageUploadServlet",
                        data:formData,
                        processData:false,
                        contentType:false,
                        success:function(res){
                            if (res.code === 1){
                                $("#reviewImg").attr("src", res.message);
                                $("#goodsImgPath").val(res.message);
                            }
                        }
                    });
                }
            </script>
            <div class="form-group"><label class="col-sm-3 control-label no-padding-right" for="form-field-5"> 最高回收价 </label>
                <div class="col-sm-9"><input type="text" id="form-field-5" name="goodsCost" placeholder="最高回收价" class="col-xs-10 col-sm-10"></div>
            </div>

            <div class="form-group"><label class="col-sm-3 control-label no-padding-right" for="form-field-6"> 最低回收价 </label>
                <div class="col-sm-9"><input type="text" id="form-field-6" name="goodsMinPrice" placeholder="最低回收价" class="col-xs-10 col-sm-10"></div>
            </div>

            <!--按钮操作-->
            <div class="Button_operation">
                <button  class="btn btn-primary radius" type="submit"><i class="fa fa-save "></i> 提交</button>
                <a href="products_list.jsp" class="btn btn-default radius" type="button">&nbsp;&nbsp;取消&nbsp;&nbsp;</a>
            </div>
        </div>

    </div>
    <!--评估配置-->
    <div class="Assign_style">
        <div class="title_name">评估配置</div>
        <div class="Select_Competence" style="padding: 10px 20px;">
            <c:forEach items="${basicInfoList}" var="basicInfo">
            <h5 style="background: lightgray; padding: 5px;">${basicInfo.basicInfoName}</h5>
                <c:forEach items="${basicInfo.infoDetailList}" var="infoDetail">
                    <div style="padding: 3px 10px;">
                        <input type="checkbox" name="infoDetailId" value="${infoDetail.infoDetailId}"/><label style="padding-left: 10px;">${infoDetail.infoDetailName}</label>
                        <input type="text" name="price_${infoDetail.infoDetailId}" placeholder="选项扣除金额" style="height: 20px;" />
                    </div>
                </c:forEach>
            </c:forEach>
        </div>
    </div>
</div>
</form>
</body>
</html>
<script type="text/javascript">
    $(function(){
        $.post(
            "CategoryListForAjaxServlet",
            function(res){
                if (res.code === 1){
                    var categoryArr = res.data;
                    for (var i = 0; i < categoryArr.length; i++){
                        var category = categoryArr[i];
                        var optionStr = "<option value='"+category.categoryId+"'>"+category.categoryName+"</option>";
                        $("#categorySelect").append(optionStr);
                    }
                } else {
                    layer.msg('加载失败!',{icon: 5,time:1000});
                }
            },
            "json"
        );
    });

    $("#categorySelect").change(
        function(){
            var categoryId = $("#categorySelect").val();
            //Clear existing brands.
            $("#brandSelect").html("<option value=''>请选择商品品牌</option>");
            if (categoryId !== ""){
                //Send Ajax request.
                $.post(
                    "BrandListForAjaxServlet",
                    {categoryId:categoryId},
                    function(res){
                        //Process brand list.
                        if (res.code === 1){
                            var brandArr = res.data;
                            //Traverse display brand dropdown menu.
                            for (var i = 0; i < brandArr.length; i++){
                                var brand = brandArr[i];
                                var optionStr = "<option value='"+brand.brandId+"'>"+brand.brandName+"</option>";
                                $("#brandSelect").append(optionStr);
                            }
                        } else {
                            layer.msg('加载失败!',{icon: 5,time:1000});
                        }
                    },
                    "json"
                );
            }
        }
    );
</script>
<script type="text/javascript">
    //初始化宽度、高度
    $(".left_Competence_add,.Competence_add_style").height($(window).height()).val();;
    $(".Assign_style").width($(window).width()-500).height($(window).height()).val();
    $(".Select_Competence").width($(window).width()-500).height($(window).height()-40).val();
    //当文档窗口发生改变时 触发
    $(window).resize(function(){

        $(".Assign_style").width($(window).width()-500).height($(window).height()).val();
        $(".Select_Competence").width($(window).width()-500).height($(window).height()-40).val();
        $(".left_Competence_add,.Competence_add_style").height($(window).height()).val();;
    });
    /*字数限制*/
    function checkLength(which) {
        var maxChars = 200; //
        if(which.value.length > maxChars){
            layer.open({
                icon:2,
                title:'提示框',
                content:'您出入的字数超多限制!',
            });
            // 超过限制的字数了就将 文本框中的内容按规定的字数 截取
            which.value = which.value.substring(0,maxChars);
            return false;
        }else{
            var curr = maxChars - which.value.length; //250 减去 当前输入的
            document.getElementById("sy").innerHTML = curr.toString();
            return true;
        }
    };
    /*按钮选择*/
    $(function(){
        $(".permission-list dt input:checkbox").click(function(){
            $(this).closest("dl").find("dd input:checkbox").prop("checked",$(this).prop("checked"));
        });
        $(".permission-list2 dd input:checkbox").click(function(){
            var l =$(this).parent().parent().find("input:checked").length;
            var l2=$(this).parents(".permission-list").find(".permission-list2 dd").find("input:checked").length;
            if($(this).prop("checked")){
                $(this).closest("dl").find("dt input:checkbox").prop("checked",true);
                $(this).parents(".permission-list").find("dt").first().find("input:checkbox").prop("checked",true);
            }
            else{
                if(l==0){
                    $(this).closest("dl").find("dt input:checkbox").prop("checked",false);
                }
                if(l2==0){
                    $(this).parents(".permission-list").find("dt").first().find("input:checkbox").prop("checked",false);
                }
            }

        });
    });

</script>
