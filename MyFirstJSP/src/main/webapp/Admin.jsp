<%@ page isELIgnored="false" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <!DOCTYPE html>
        <html lang="th">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>IT Requisition - Admin (Responsive)</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

            <style>
                /* Grid System - Responsive */
                .admin-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                    gap: 25px;
                    padding: 40px 20px;
                    max-width: 1400px;
                    margin: 0 auto;
                }

                /* Card Design */
                .card {
                    background: white;
                    border: 3px solid #3272BB;
                    border-radius: 20px;
                    padding: 30px 15px;
                    text-align: center;
                    cursor: pointer;


                    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);

                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    min-height: 300px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                }

                .card:hover {

                    transform: translateY(-10px);
                    box-shadow: 0 15px 30px rgba(50, 114, 187, 0.2);
                    border-color: #003366;
                }

                .card:active {
                    transform: translateY(-2px);
                    box-shadow: 0 5px 10px rgba(50, 114, 187, 0.1);
                }


                .card:hover i {
                    color: #003366;
                    transform: scale(1.1);

                    transition: all 0.3s ease;
                }

                .card i {
                    font-size: 90px;
                    color: #3272BB;
                    margin-bottom: 20px;
                    transition: all 0.3s ease;
                }

                /* ขนาดข้อความ */
                .card p {
                    font-weight: bold;
                    font-size: 20px;
                    color: #003366;
                    margin: 0;
                    line-height: 1.3;
                }

                .contact-info p {
                    margin: 0;
                    white-space: nowrap;
                }

                @media (max-width: 400px) {
                    .admin-grid {
                        grid-template-columns: 1fr;
                        padding: 20px 15px;
                    }

                    .card {
                        min-height: 250px;
                    }
                }
            </style>
        </head>

        
            <div id="mySidebar" class="sidebar">
            <a href="javascript:void(0)" class="closebtn" onclick="toggleNav()">&times;</a>
            <a href="${pageContext.request.contextPath}" style='font-size:20px'>Home</a>
            <a href="${pageContext.request.contextPath}/submit.jsp" style='font-size:20px'>Submitted Forms</a>
            <a href="${pageContext.request.contextPath}/form.jsp" style='font-size:20px'>New Form</a>
            <a href='${pageContext.request.contextPath}/Admin.jsp' class='admin-tab'><i class='fa fa-circle-user' style='font-size:36px;padding-left:0px;padding-right:25%'></i>Admin</a>
            </div>

            <div id='main'>
           
            <div class='sticky-bar'>
                <i id="menuBtn" class="fa fa-bars" onclick="toggleNav()" style="font-size:36px; cursor:pointer; padding-left:5px; padding-right:5px;"></i>
                </i><img src="${pageContext.request.contextPath}/images/MoF.png" alt="MoF Logo" style="height: 48px; padding-left: 10px; padding-right: 5px">
                </i><img src="${pageContext.request.contextPath}/images/SLF_logo.png" alt="SLF Logo" style="height: 48px; padding-left: 5px; padding-right: 5px">
                <div style="margin-left:auto;display:flex;align-items:center">
                    <i class='fa fa-circle-user' style='font-size:24px;padding-left:10px;padding-right:0px'></i>
                    <p style='margin-left: 5px;margin-right: 15px'>สอบถามข้อมูลเพิ่มเติม ติดต่อ 411</p>
                </div>
            </div>

            <div class ='blue-title'>
                <h1 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ฝ่ายเทคโนโลยีสารสนเทศ กองทุนเงินกู้ยืมเพื่อการศึกษา</h1>
                <h2 style='margin-block-start: 0.1em; margin-block-end: 0.1em;'>ใบขอให้ดำเนินการ / Requisition Form</h2>
            </div>

            <div class="admin-grid">
                <div class="card" onclick="location.href='${pageContext.request.contextPath}/DirectorApprove.jsp'">
                    <i class="fa-regular fa-circle-user"></i>
                    <p>ผู้อำนวยการฝ่าย</p>
                </div>

                <div class="card" onclick="location.href='${pageContext.request.contextPath}/TechnicalApprove.jsp'">
                    <i class="fa-solid fa-screwdriver-wrench"></i>
                    <p>ความเห็นและการอนุมัติเชิงเทคนิค</p>
                </div>

                <div class="card" onclick="location.href='${pageContext.request.contextPath}/ITDirectorApprove.jsp'">
                    <i class="fa-regular fa-circle-user"></i>
                    <p>ผู้อำนวยการฝ่าย<br>เทคโนโลยีสารสนเทศ</p>
                </div>

                <div class="card" onclick="location.href='${pageContext.request.contextPath}/Process.jsp'">
                    <i class="fa-regular fa-circle-user"></i>
                    <p>รายละเอียดการดำเนินการ</p>
                </div>
            </div>

            <script>
            function toggleNav() {
            var sidebar = document.getElementById("mySidebar");
            var main = document.getElementById("main");
            
            if (sidebar.style.width === "250px") {
                // Return to normal
                sidebar.style.width = "0";
                main.style.marginLeft = "0";
                main.style.width = "100%";
            } else {
                // Shrink the main area
                sidebar.style.width = "250px";
                main.style.marginLeft = "250px";
                // This is the magic line:
                main.style.width = "calc(100% - 250px)"; 
            }
            }
            </script>
            </div>

        </html>