#include <boost/python.hpp>
#include <boost/python/list.hpp>
#include "ICTCLAS50.h"

using namespace boost::python;

bool ict_init(const char* pDirPath)
{
    return ICTCLAS_Init(pDirPath);
}

bool ict_exit()
{
    return ICTCLAS_Exit();
}

unsigned int import_dict(const char *sFilename,eCodeType codeType)
{
    return ICTCLAS_ImportUserDictFile(sFilename,codeType);
}

list process_str_ret_list(const char *sParag,int iLength,eCodeType codeType)
{
    int pResultCount=0;
    const tagICTCLAS_Result* re= ICTCLAS_ParagraphProcessA(sParag,iLength,pResultCount,codeType,false);
    list result;
    printf("the length is %d\n",pResultCount);
    for (int i=0;i<pResultCount;i++)
    {
        result.append(re[i]);
    }
    return result;
}

BOOST_PYTHON_MODULE(ictclas)
{
    class_<tagICTCLAS_Result>("tagICTCLAS_Result")
        .def_readonly("iStartPos",&tagICTCLAS_Result::iStartPos)
        .def_readonly("iLength",&tagICTCLAS_Result::iLength);
    enum_<eCodeType>("eCodeType")
        .value("UNKNOW",CODE_TYPE_UNKNOWN)
        .value("ASCII",CODE_TYPE_ASCII)
        .value("GB",CODE_TYPE_GB)
        .value("UTF8",CODE_TYPE_UTF8)
        .value("BIG5",CODE_TYPE_BIG5);

    def("ict_init",ict_init);
    def("ict_exit",ict_exit);
    def("import_dict",import_dict);
    def("process_str_ret_list",process_str_ret_list);
}
