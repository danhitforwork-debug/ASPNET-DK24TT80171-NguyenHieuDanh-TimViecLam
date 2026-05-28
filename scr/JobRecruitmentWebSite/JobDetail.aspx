<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

string connStr =
    ConfigurationManager.ConnectionStrings["JobDb"].ConnectionString;

protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        LoadDetail();
    }
}

void LoadDetail()
{
    int id;

    if (!int.TryParse(Request.QueryString["id"], out id))
    {
        lblTitle.Text = "Không tìm thấy việc làm.";
        return;
    }

    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT
            j.*,
            c.CategoryName,
            p.ProvinceName,
            t.JobTypeName
        FROM Jobs j
        INNER JOIN Categories c
            ON j.CategoryId = c.CategoryId
        INNER JOIN Provinces p
            ON j.ProvinceId = p.ProvinceId
        INNER JOIN JobTypes t
            ON j.JobTypeId = t.JobTypeId
        WHERE j.JobId = @id", conn))
    {
        cmd.Parameters.AddWithValue("@id", id);

        conn.Open();

        SqlDataReader r = cmd.ExecuteReader();

        if (r.Read())
        {
            lblTitle.Text =
                r["Title"].ToString();

            lblInfo.Text =
                "Công ty: " + r["CompanyName"] +
                " | Ngành: " + r["CategoryName"] +
                " | Tỉnh/thành: " + r["ProvinceName"] +
                " | Loại: " + r["JobTypeName"] +
                " | Lương: " + r["Salary"];

            lblDescription.Text =
                r["Description"].ToString();

            lnkApply.NavigateUrl =
                "Apply.aspx?id=" + id;
                if (r["ImageFile"] != DBNull.Value &&
    r["ImageFile"].ToString() != "")
{
    imgJob.ImageUrl =
        "~/Uploads/" + r["ImageFile"].ToString();

    imgJob.Visible = true;
}
else
{
    imgJob.Visible = false;
}
        }
        else
        {
            lblTitle.Text =
                "Không tìm thấy việc làm.";
        }
    }
}

</script>

<!DOCTYPE html>

<html>

<head runat="server">

    <title>Chi tiết việc làm</title>

    <link href="Styles.css?v=10" rel="stylesheet" />

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

    <h2>
        <asp:Label
            ID="lblTitle"
            runat="server" />
    </h2>
    <div class="job-image-box">
    <asp:Image
        ID="imgJob"
        runat="server"
        CssClass="job-image"
        Visible="false" />
    </div>
   

    <p style="margin-top:15px;">

        <asp:Label
            ID="lblInfo"
            runat="server" />

    </p>

    <hr />

    <div style="margin-top:20px; line-height:28px;">

        <asp:Label
            ID="lblDescription"
            runat="server" />

    </div>

    <div style="margin-top:30px;">

        <asp:HyperLink
            ID="lnkApply"
            runat="server"
            CssClass="btn">

            Ứng tuyển ngay

        </asp:HyperLink>

    </div>

</div>

</form>

</body>
</html>