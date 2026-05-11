<%@ page isELIgnored="false" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
* {
    box-sizing: border-box;
}

.sticky-bar{
    position: sticky;
    top: 0;
    background: white;
    width: 100%;
    height: 10%;
    border-bottom: 5px solid #3272BB;
    align-items: center;
    display:flex;
    padding-left: 20px;
}
html, body{
    margin: 0px;
    padding: 0;
    font-family: 'DBHelvethaica', sans-serif;
    width: 100%;
    height:100%;
}

.blue-title {
    background: #C3EAFF;
    height: 12%;
    width: 100%;
    justify-content: center;
    align-items:center;
    text-align:center;
    display:flex;
    flex-direction: column;
}

.options-div {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap; /* This allows boxes to drop to the next line instead of pushing the page wide */
    justify-content: center;
    align-items: center;
    text-align: center;
    width: 100%;
}

.option-box {
    border: solid 5px #3272BB;
    height: 440px;
    width: 100%;        /* Default to full width on mobile */
    max-width: 400px;   /* Won't grow larger than 400px */
    margin: 20px;       /* Simplified margin */
}

.option-pic{
    height: 200px;
    margin-left: 15px;
    margin-right: 15px;
    margin-top: 50px;
    margin-bottom: 50px;
    font-size: 200px;
}



</style>
<html>
<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>


<div class='sticky-bar'>
    <i class="fa fa-bars" style="font-size:36px;padding-left:5px;padding-right:5px;">
    </i><img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
    </i><img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <span  class="material-icons user-icon">account_circle</span>
    <p>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
</div>


<div class ='blue-title'>
    <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
    <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
</div>


<div class="options-div">

    <div class='option-box'>
        <div class='option-pic'>
            <i class="fa fa-plus"></i>
        </div >
        <h2>New Form</h2>
    </div>

    <div class='option-box'>
        <div class='option-pic'>
            <i class="fa fa-list"></i>
        </div>
        <h2>Pending</h2>
    </div>

    <div class='option-box'>
        <div class='option-pic'>
            <i class="fa fa-paper-plane"></i>
        </div>
        <h2>Submit</h2>
    </div>

</div>
</html>