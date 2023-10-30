package com.qfedu.mtlms.servlets;

import com.qfedu.mtlms.dto.Category;
import com.qfedu.mtlms.service.CategoryService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/CategoryLoadServlet")
public class CategoryLoadServlet extends HttpServlet {
    private static final CategoryService CATEGORY_SERVICE = new CategoryService();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //Category listings.
        List<Category> categoryList = CATEGORY_SERVICE.listCategories();
        //Transmitter data.
        req.setAttribute("categoryList", categoryList);
        req.getRequestDispatcher("brand_add.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doPost(req, resp);
    }
}
