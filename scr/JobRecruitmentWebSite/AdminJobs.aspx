<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">

string connStr = ConfigurationManager.ConnectionStrings["JobDb"].ConnectionString;

protected void Page_Load(object sender, EventArgs e)
{
    if (Session["RoleName"] == null || Session["RoleName"].ToString() != "Admin")
    {
        Response.Redirect("Login.aspx");
    }

    if (!IsPostBack)
    {
        LoadDropdowns();
        LoadGrid();
    }
}

void LoadDropdowns()
{
    LoadDropDown(ddlCategory, "SELECT CategoryId, CategoryName FROM Categories", "CategoryName", "CategoryId");
    LoadDropDown(ddlProvince, "SELECT ProvinceId, ProvinceName FROM Provinces", "ProvinceName", "ProvinceId");
    LoadDropDown(ddlJobType, "SELECT JobTypeId, JobTypeName FROM JobTypes", "JobTypeName", "JobTypeId");
}

void LoadDropDown(DropDownList ddl, string sql, string text, string value)
{
    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
    {
        DataTable dt = new DataTable();
        da.Fill(dt);

        ddl.DataSource = dt;
        ddl.DataTextField = text;
        ddl.DataValueField = value;
        ddl.DataBind();
    }
}

void LoadGrid()
{
    string sql = @"
        SELECT
            j.JobId,
            j.Title,
            c.CategoryName,
            p.ProvinceName,
            t.JobTypeName,
            j.CompanyName,
            j.Salary
        FROM Jobs j
        INNER JOIN Categories c ON j.CategoryId = c.CategoryId
        INNER JOIN Provinces p ON j.ProvinceId = p.ProvinceId
        INNER JOIN JobTypes t ON j.JobTypeId = t.JobTypeId
        ORDER BY j.JobId DESC";

    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
    {
        DataTable dt = new DataTable();
        da.Fill(dt);

        gvJobs.DataSource = dt;
        gvJobs.DataBind();
    }
}

string SaveJobImage()
{
    if (!fuJobImage.HasFile)
        return "";

    string ext = Path.GetExtension(fuJobImage.FileName).ToLower();

    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
    {
        lblMsg.Text = "Chỉ upload hình JPG, JPEG, PNG.";
        return "";
    }

    string fileName =
        DateTime.Now.ToString("yyyyMMddHHmmss") + "_" +
        Path.GetFileName(fuJobImage.FileName);

    fuJobImage.SaveAs(Server.MapPath("~/Uploads/" + fileName));

    return fileName;
}

protected void btnInsert_Click(object sender, EventArgs e)
{
    string imageFile = SaveJobImage();

    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(@"
        INSERT INTO Jobs
        (
            Title,
            CategoryId,
            ProvinceId,
            JobTypeId,
            CompanyName,
            Salary,
            Description,
            ImageFile
        )
        VALUES
        (
            @t,
            @c,
            @p,
            @ty,
            @co,
            @s,
            @d,
            @img
        )", conn))
    {
        AddParams(cmd);
        cmd.Parameters.AddWithValue("@img", imageFile);

        conn.Open();
        cmd.ExecuteNonQuery();
    }

    lblMsg.Text = "Đã thêm tin tuyển dụng.";
    ClearForm();
    LoadGrid();
}

protected void btnUpdate_Click(object sender, EventArgs e)
{
    if (hfJobId.Value == "")
    {
        lblMsg.Text = "Bấm Sửa trước.";
        return;
    }

    string imageFile = SaveJobImage();

    string sql = @"
        UPDATE Jobs
        SET
            Title = @t,
            CategoryId = @c,
            ProvinceId = @p,
            JobTypeId = @ty,
            CompanyName = @co,
            Salary = @s,
            Description = @d";

    if (imageFile != "")
    {
        sql += ", ImageFile = @img";
    }

    sql += " WHERE JobId = @id";

    using (SqlConnection conn = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
        AddParams(cmd);

        if (imageFile != "")
        {
            cmd.Parameters.AddWithValue("@img", imageFile);
        }

        cmd.Parameters.AddWithValue("@id", int.Parse(hfJobId.Value));

        conn.Open();
        cmd.ExecuteNonQuery();
    }

    lblMsg.Text = "Đã cập nhật.";
    ClearForm();
    LoadGrid();
}

void AddParams(SqlCommand cmd)
{
    cmd.Parameters.AddWithValue("@t", txtTitle.Text.Trim());
    cmd.Parameters.AddWithValue("@c", int.Parse(ddlCategory.SelectedValue));
    cmd.Parameters.AddWithValue("@p", int.Parse(ddlProvince.SelectedValue));
    cmd.Parameters.AddWithValue("@ty", int.Parse(ddlJobType.SelectedValue));
    cmd.Parameters.AddWithValue("@co", txtCompany.Text.Trim());
    cmd.Parameters.AddWithValue("@s", txtSalary.Text.Trim());
    cmd.Parameters.AddWithValue("@d", txtDescription.Text.Trim());
}

protected void gvJobs_RowCommand(object sender, GridViewCommandEventArgs e)
{
    int rowIndex = Convert.ToInt32(e.CommandArgument);
    int id = Convert.ToInt32(gvJobs.DataKeys[rowIndex].Value);

    if (e.CommandName == "DeleteJob")
    {
        using (SqlConnection conn = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("DELETE FROM Jobs WHERE JobId=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", id);

            conn.Open();
            cmd.ExecuteNonQuery();
        }

        lblMsg.Text = "Đã xóa.";
        LoadGrid();
    }

    if (e.CommandName == "EditJob")
    {
        using (SqlConnection conn = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("SELECT * FROM Jobs WHERE JobId=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", id);

            conn.Open();

            SqlDataReader r = cmd.ExecuteReader();

            if (r.Read())
            {
                hfJobId.Value = id.ToString();
                txtTitle.Text = r["Title"].ToString();
                ddlCategory.SelectedValue = r["CategoryId"].ToString();
                ddlProvince.SelectedValue = r["ProvinceId"].ToString();
                ddlJobType.SelectedValue = r["JobTypeId"].ToString();
                txtCompany.Text = r["CompanyName"].ToString();
                txtSalary.Text = r["Salary"].ToString();
                txtDescription.Text = r["Description"].ToString();
            }
        }
    }
}

protected void btnClear_Click(object sender, EventArgs e)
{
    ClearForm();
}

void ClearForm()
{
    hfJobId.Value = "";
    txtTitle.Text = "";
    txtCompany.Text = "";
    txtSalary.Text = "";
    txtDescription.Text = "";
}

</script>

<!DOCTYPE html>

<html>

<head runat="server">
    <title>Admin quản lý tuyển dụng</title>
    <link href="Styles.css?v=99" rel="stylesheet" />
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

<form id="form1" runat="server" enctype="multipart/form-data">

<div class="container">

    <h2>Admin - Quản lý tin tuyển dụng</h2>

    <asp:HiddenField ID="hfJobId" runat="server" />

    <p>
        <label>Tiêu đề:</label>
        <asp:TextBox ID="txtTitle" runat="server" Width="400" />
    </p>

    <p>
        <label>Ngành:</label>
        <asp:DropDownList ID="ddlCategory" runat="server" Width="420" />
    </p>

    <p>
        <label>Tỉnh/thành:</label>
        <asp:DropDownList ID="ddlProvince" runat="server" Width="420" />
    </p>

    <p>
        <label>Loại việc:</label>
        <asp:DropDownList ID="ddlJobType" runat="server" Width="420" />
    </p>

    <p>
        <label>Công ty:</label>
        <asp:TextBox ID="txtCompany" runat="server" Width="400" />
    </p>

    <p>
        <label>Lương:</label>
        <asp:TextBox ID="txtSalary" runat="server" Width="400" />
    </p>

    <p>
        <label>Mô tả:</label>
        <asp:TextBox
            ID="txtDescription"
            runat="server"
            Width="400"
            Height="100"
            TextMode="MultiLine" />
    </p>

    <p>
        <label>Hình công việc:</label>
        <asp:FileUpload ID="fuJobImage" runat="server" />
    </p>

    <asp:Button
        ID="btnInsert"
        runat="server"
        Text="Thêm mới"
        OnClick="btnInsert_Click" />

    <asp:Button
        ID="btnUpdate"
        runat="server"
        Text="Cập nhật"
        OnClick="btnUpdate_Click" />

    <asp:Button
        ID="btnClear"
        runat="server"
        Text="Làm mới"
        OnClick="btnClear_Click" />

    <p class="msg">
        <asp:Label ID="lblMsg" runat="server" />
    </p>

    <asp:GridView
        ID="gvJobs"
        runat="server"
        CssClass="grid"
        AutoGenerateColumns="False"
        DataKeyNames="JobId"
        OnRowCommand="gvJobs_RowCommand">

        <Columns>

            <asp:BoundField DataField="JobId" HeaderText="ID" />
            <asp:BoundField DataField="Title" HeaderText="Tiêu đề" />
            <asp:BoundField DataField="CategoryName" HeaderText="Ngành" />
            <asp:BoundField DataField="ProvinceName" HeaderText="Tỉnh" />
            <asp:BoundField DataField="JobTypeName" HeaderText="Loại" />
            <asp:BoundField DataField="CompanyName" HeaderText="Công ty" />
            <asp:BoundField DataField="Salary" HeaderText="Lương" />

            <asp:ButtonField
                Text="Sửa"
                CommandName="EditJob"
                ButtonType="Button" />

            <asp:ButtonField
                Text="Xóa"
                CommandName="DeleteJob"
                ButtonType="Button" />

        </Columns>

    </asp:GridView>

</div>

</form>

</body>
</html>