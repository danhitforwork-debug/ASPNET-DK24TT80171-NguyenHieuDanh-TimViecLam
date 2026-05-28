<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

string connStr =
    ConfigurationManager.ConnectionStrings["JobDb"].ConnectionString;

protected void btnLogin_Click(
    object sender,
    EventArgs e)
{
    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(
        "SELECT UserId, FullName, RoleName FROM Users WHERE Username=@u AND Password=@p",
        conn))
    {
        cmd.Parameters.AddWithValue(
            "@u",
            txtUsername.Text.Trim()
        );

        cmd.Parameters.AddWithValue(
            "@p",
            txtPassword.Text.Trim()
        );

        conn.Open();

        SqlDataReader r = cmd.ExecuteReader();

        if (r.Read())
        {
            Session["UserId"] =
                r["UserId"].ToString();

            Session["FullName"] =
                r["FullName"].ToString();

            Session["RoleName"] =
                r["RoleName"].ToString();

            Response.Redirect(
                r["RoleName"].ToString() == "Admin"
                ? "AdminJobs.aspx"
                : "Default.aspx"
            );
        }
        else
        {
            lblMsg.Text =
                "Sai tên đăng nhập hoặc mật khẩu.";
        }
    }
}

</script>

<!DOCTYPE html>

<html>

<head runat="server">

    <title>Đăng nhập</title>

    <link href="Styles.css?v=20" rel="stylesheet" />

</head>

<body>

<div class="header">

    <div>
        <b>Website tìm việc làm</b>
    </div>

    <div>
        <a href="Default.aspx">Trang chủ</a>
        <a href="Login.aspx">Đăng nhập</a>
        <a href="AdminJobs.aspx">Admin quản lý tuyển dụng</a>
        <a href="AdminApplications.aspx">Hồ sơ</a>
        <a href="Logout.aspx">Thoát</a>
    </div>

</div>

<form id="form1" runat="server">

<div class="container">

    <h2>Đăng nhập</h2>

    <p>

        <label>Tài khoản:</label>

        <asp:TextBox
            ID="txtUsername"
            runat="server" />

    </p>

    <p>

        <label>Mật khẩu:</label>

        <asp:TextBox
            ID="txtPassword"
            runat="server"
            TextMode="Password" />

    </p>

    <asp:Button
        ID="btnLogin"
        runat="server"
        Text="Đăng nhập"
        OnClick="btnLogin_Click" />

    <p class="msg">

        <asp:Label
            ID="lblMsg"
            runat="server" />

    </p>

    <hr />

    <p>
        Admin:
        <b>admin / admin123</b>
    </p>

    <p>
        User:
        <b>user / user123</b>
    </p>

</div>

</form>

</body>
</html>