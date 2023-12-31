#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "qDebug"
#include "qFileDialog"
#include "qMessageBox"
#include "QFontDialog"
#include "QSettings"
#include "CodeTextEdit.h"

#if defined(QT_PRINTSUPPORT_LIB)
#include <QtPrintSupport/qtprintsupportglobal.h>
#if QT_CONFIG(printer)
#if QT_CONFIG(printdialog)
#include <QPrintDialog>
#endif
#include <QPrinter>
#endif
#endif

//保存打开历史记录
void saveHistory(QString path);
//获取历史记录
QList<QString> getHistory();

QSettings * mSettings;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    this->setCentralWidget(ui->tabWidget);
    if (mSettings == NULL){
        mSettings = new QSettings("history.ini", QSettings::IniFormat);
    }
    //getHistory();
    initMenu();
#if !QT_CONFIG(printer)
    ui->print->setEnabled(false);
#endif
}

MainWindow::~MainWindow()
{
    delete ui;
}

//初始化菜单
void MainWindow::initMenu()
{
    //获取Menu
    QMenu *recent = this->findChild<QMenu *>("recent");
    //qDebug()<<recent->title();
    //获取Action
    QList<QObject *> chlists = recent->children();
    foreach (QObject * ch,chlists){
        QAction *action = (QAction *)ch;
        //清空子菜单Action
        recent->removeAction(action);
    }
    QList lists = getHistory();

    for (int i = lists.size()-1; i>=0; i--) {
        //生成子菜单Action
        recent->addAction(lists[i], this, &MainWindow::on_open_recent_file);
    }

    if (lists.size() > 0) {
        recent->addAction("清除历史记录", this, &MainWindow::on_clear_history_triggered, QKeySequence("Ctrl+Alt+Shift+c"));
    }
}

//获取历史记录
QList<QString> getHistory(){
    //打开开始读
    int size = mSettings->beginReadArray("history");

    //创建返回对象
    QList<QString> lists;
    for (int i = 0; i<size; i++){
        mSettings->setArrayIndex(i);
        //QString path = mSettings->value("path").toString();
        lists.append(mSettings->value("path").toString());
        //qDebug()<<i<<path;
    }
    //关闭读
    mSettings->endArray();
    return lists;
}

//保存打开历史记录
void saveHistory(QString path){
    //获取历史记录
    QList<QString> lists = getHistory();
    //通过循环去除里面相同的历史记录
    foreach (QString str,lists) {
        if (str == path) {
            lists.removeOne(str);
        }
    }
    lists.append(path);
    //开始写入
    mSettings->beginWriteArray("history");
    for (int i = 0; i<lists.size(); i++) {
        mSettings->setArrayIndex(i);
        //保存字符串
        mSettings->setValue("path", lists[i]);
    }
    //关闭开始写入
    mSettings->endArray();
}

//打开文件
void MainWindow::on_open_recent_file()
{
    QAction *action = (QAction *)sender();

    QString fileName = action->text();

    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly|QFile::Text)) {
        QMessageBox::warning(this, "警告", "无法打开此文件" + file.errorString());
        return;
    }
    currentFile = fileName;
    setWindowTitle(fileName);
    QTextStream in(&file);
    QString text = in.readAll();
    ui->textEdit->setText(text);
    file.close();

    saveHistory(currentFile);
    initMenu();
}

//新建文件
void MainWindow::on_new_file_triggered()
{
    setWindowTitle("未命名文件");
    CodeTextEdit * textedit = new CodeTextEdit();
    ui->tabWidget->addTab(textedit, "NewTab.txt");

//    currentFile.clear();A
//    ui->textEdit->setText("");
//    setWindowTitle("未命名文件");
}

//打开文件
void MainWindow::on_open_file_triggered()
{
    QString fileName = QFileDialog::getOpenFileName(this, "打开文件");
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QFile::Text)) {
        QMessageBox::warning(this, "警告", "无法打开此文件" + file.errorString());
        return;
    }
    currentFile = fileName;
    setWindowTitle(fileName);
    QTextStream in(&file);
    QString text = in.readAll();
    ui->textEdit->setText(text);
    file.close();

    saveHistory(currentFile);
    initMenu();
}

//保存文件
void MainWindow::on_save_file_triggered()
{
    QString fileName;
    if (currentFile.isEmpty()) {
        fileName = QFileDialog::getSaveFileName(this, "保存文件");
        currentFile = fileName;
    } else {
        fileName = currentFile;
    }
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QFile::Text)) {
        QMessageBox::warning(this, "警告", "无法保存文件" + file.errorString());
        return;
    }
    setWindowTitle(fileName);
    QTextStream out(&file);
    QString text = ui->textEdit->toPlainText();  //toHtml()
    out<<text;
    file.close();
    saveHistory(currentFile);
    initMenu();
}

//另存为
void MainWindow::on_save_as_triggered()
{
    QString fileName;
    fileName = QFileDialog::getSaveFileName(this, "另存文件");
    currentFile = fileName;
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QFile::Text)) {
        QMessageBox::warning(this, "警告", "无法保存文件" + file.errorString());
        return;
    }
    setWindowTitle(fileName);
    QTextStream out(&file);
    QString text = ui->textEdit->toPlainText();  //toHtml()
    out<<text;
    file.close();
    saveHistory(currentFile);
    initMenu();
}

//粘贴
void MainWindow::on_paste_triggered()
{
    ui->textEdit->paste();
}

//剪切
void MainWindow::on_cut_triggered()
{
    ui->textEdit->cut();
}

//复制
void MainWindow::on_copy_triggered()
{
    ui->textEdit->copy();
}

//加粗
void MainWindow::on_bolder_triggered(bool checked)
{
    ui->textEdit->setFontWeight(checked?QFont::Bold:QFont::Normal);
}

//斜体
void MainWindow::on_italics_triggered(bool checked)
{
    ui->textEdit->setFontItalic(checked);
}

//下划线
void MainWindow::on_underline_triggered(bool checked)
{
    ui->textEdit->setFontUnderline(checked);
}

//字体
void MainWindow::on_font_triggered()
{
    bool fontSelected;
    QFont font = QFontDialog::getFont(&fontSelected, this);
    if (fontSelected) {
        ui->textEdit->setFont(font);
    }
}

//关于
void MainWindow::on_about_triggered()
{
    QMessageBox::about(this, "关于", "此版本已经进过一段时间的开发并拥有了历史记录功能\n群号962910965\n\n版本号0.2");
}

//打印
void MainWindow::on_print_triggered()
{
#if defined(QT_PRINTSUPPORT_LIB) && QT_CONFIG(printer)
    QPrinter printDev;
#if QT_CONFIG(printdialog)
    QPrintDialog dialog(&printDev, this);
    if (dialog.exec() == QDialog::Rejected)
        return;
#endif
    ui->textEdit->print(&printDev);
#endif
}

//退出
void MainWindow::on_exit_triggered()
{
    QCoreApplication::exit();
}

//撤销
void MainWindow::on_undo_triggered()
{
    ui->textEdit->undo();
}

//取消撤销
void MainWindow::on_redo_triggered()
{
    ui->textEdit->redo();
}

void MainWindow::on_clear_history_triggered()
{
    //qDebug()<<"on_clear_history_triggered..";
    mSettings->remove("history");
    initMenu();
}
