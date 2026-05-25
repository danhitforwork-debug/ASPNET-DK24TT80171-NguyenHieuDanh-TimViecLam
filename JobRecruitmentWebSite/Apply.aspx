<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

string connStr = ConfigurationManager.ConnectionStrings["JobDb"].ConnectionString;

int JobId
{
    get
    {
        int id;
        int.TryParse(Request.QueryString["id"], out id);
        return id;
    }
}

protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
        LoadJob();
}

void LoadJob()
{
    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand("SELECT Title FROM Jobs WHERE JobId=@id", conn))
    {
        cmd.Parameters.AddWithValue("@id", JobId);

        conn.Open();

        object title = cmd.ExecuteScalar();

        lblJob.Text = title == null
            ? "Không tìm thấy việc làm"
            : title.ToString();
    }
}

protected void btnApply_Click(object sender, EventArgs e)
{
    string fileName = "";

    if (fuCv.HasFile)
    {
        string ext = Path.GetExtension(fuCv.FileName).ToLower();

        if (ext != ".pdf" &&
            ext != ".doc" &&
            ext != ".docx" &&
            ext != ".jpg" &&
            ext != ".jpeg" &&
            ext != ".png")
        {
            lblMsg.Text = "Chỉ upload PDF, DOC, DOCX, JPG, JPEG, PNG.";
            return;
        }

        fileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" +
                   Path.GetFileName(fuCv.FileName);

        fuCv.SaveAs(Server.MapPath("~/Uploads/" + fileName));
    }

    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(
        "INSERT INTO Applications(JobId,FullName,Phone,Email,CvFile) VALUES(@j,@n,@p,@e,@cv)", conn))
    {
        cmd.Parameters.AddWithValue("@j", JobId);
        cmd.Parameters.AddWithValue("@n", txtFullName.Text.Trim());
        cmd.Parameters.AddWithValue("@p", txtPhone.Text.Trim());
        cmd.Parameters.AddWithValue("@e", txtEmail.Text.Trim());
        cmd.Parameters.AddWithValue("@cv", fileName);

        conn.Open();
        cmd.ExecuteNonQuery();
    }

    string hoTen = txtFullName.Text.Trim().Replace("'", "\\'");

    string script =
        "alert('Chúc mừng " + hoTen +
        " đã ứng tuyển thành công\\nChúng tôi sẽ liên hệ bạn trong thời gian sớm nhất');" +
        "window.location='Default.aspx';";

    ClientScript.RegisterStartupScript(
        this.GetType(),
        "success",
        script,
        true
    );
}

</script>

<!DOCTYPE html>
<html>

<head runat="server">
    <title>Ứng tuyển</title>
    <link href="Styles.css" rel="stylesheet" />
</head>

<body>

<div class="header">

    <div>
        <b>Website tìm việc làm</b>
    </div>

    <div>
        <a href="Default.aspx">Trang chủ</a>
        <a href="Login.aspx">Đăng nhập</a>
        <a href="AdminJobs.aspx">Admin tin tuyển dụng</a>
        <a href="AdminApplications.aspx">Hồ sơ</a>
        <a href="Logout.aspx">Thoát</a>
    </div>

</div>

<form id="form1" runat="server" enctype="multipart/form-data">

<div class="container">

    <h2>
        Ứng tuyển:
        <asp:Label ID="lblJob" runat="server" />
    </h2>

    <p>
        <label>Họ tên:</label>
        <asp:TextBox ID="txtFullName" runat="server" />
    </p>

    <p>
        <label>SĐT:</label>
        <asp:TextBox ID="txtPhone" runat="server" />
    </p>

    <p>
        <label>Email:</label>
        <asp:TextBox ID="txtEmail" runat="server" />
    </p>

    <p>
        <label>Upload CV:</label>
        <asp:FileUpload ID="fuCv" runat="server" />
    </p>

    <asp:Button
        ID="btnApply"
        runat="server"
        Text="Gửi hồ sơ"
        OnClick="btnApply_Click" />

    <p class="msg">
        <asp:Label ID="lblMsg" runat="server" />
    </p>

</div>

</form>

</body>
</html>