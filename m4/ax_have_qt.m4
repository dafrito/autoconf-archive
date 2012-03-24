# ===========================================================================
#        http://www.gnu.org/software/autoconf-archive/ax_have_qt.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_HAVE_QT [--with-Qt-dir=DIR] [--with-Qt-lib-dir=DIR] [--with-Qt-lib=LIB]
#   AX_HAVE_QT [--with-Qt-include-dir=DIR] [--with-Qt-bin-dir=DIR] [--with-Qt-lib-dir=DIR] [--with-Qt-lib=LIB]
#
# DESCRIPTION
#
#   Searches common directories for Qt include files, libraries and Qt
#   binary utilities. The macro supports several different versions of the
#   Qt framework being installed on the same machine. Without options, the
#   macro is designed to look for the latest library, i.e., the highest
#   definition of QT_VERSION in qglobal.h. By use of one or more options a
#   different library may be selected. There are two different sets of
#   options. Both sets contain the option --with-Qt-lib=LIB which can be
#   used to force the use of a particular version of the library file when
#   more than one are available. LIB must be in the form as it would appear
#   behind the "-l" option to the compiler. Examples for LIB would be
#   "qt-mt" for the multi-threaded version and "qt" for the regular version.
#   In addition to this, the first set consists of an option
#   --with-Qt-dir=DIR which can be used when the installation conforms to
#   Trolltech's standard installation, which means that header files are in
#   DIR/include, binary utilities are in DIR/bin and the library is in
#   DIR/lib. The second set of options can be used to indicate individual
#   locations for the header files, the binary utilities and the library
#   file, in addition to the specific version of the library file.
#
#   The following shell variable is set to either "yes" or "no":
#
#     have_qt
#
#   Additionally, the following variables are exported:
#
#     QT_CXXFLAGS
#     QT_LIBS
#     QT_MOC
#     QT_UIC
#     QT_LRELEASE
#     QT_LUPDATE
#     QT_DIR
#
#   which respectively contain an "-I" flag pointing to the Qt include
#   directory (and "-DQT_THREAD_SUPPORT" when LIB is "qt-mt"), link flags
#   necessary to link with Qt and X, the name of the meta object compiler
#   and the user interface compiler both with full path, and finaly the
#   variable QTDIR as Trolltech likes to see it defined (if possible).
#
#   Example lines for Makefile.in:
#
#     CXXFLAGS = @QT_CXXFLAGS@
#     MOC      = @QT_MOC@
#
#   After the variables have been set, a trial compile and link is performed
#   to check the correct functioning of the meta object compiler. This test
#   may fail when the different detected elements stem from different
#   releases of the Qt framework. In that case, an error message is emitted
#   and configure stops.
#
#   No common variables such as $LIBS or $CFLAGS are polluted.
#
#   Options:
#
#   --with-Qt-dir=DIR: DIR is equal to $QTDIR if you have followed the
#   installation instructions of Trolltech. Header files are in DIR/include,
#   binary utilities are in DIR/bin and the library is in DIR/lib.
#
#   --with-Qt-include-dir=DIR: Qt header files are in DIR.
#
#   --with-Qt-bin-dir=DIR: Qt utilities such as moc and uic are in DIR.
#
#   --with-Qt-lib-dir=DIR: The Qt library is in DIR.
#
#   --with-Qt-lib=LIB: Use -lLIB to link with the Qt library.
#
#   If some option "=no" or, equivalently, a --without-Qt-* version is given
#   in stead of a --with-Qt-*, "have_qt" is set to "no" and the other
#   variables are set to the empty string.
#
# LICENSE
#
#   Copyright (c) 2008 Bastiaan Veelo <Bastiaan@Veelo.net>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 10

AU_ALIAS([BNV_HAVE_QT], [AX_HAVE_QT])
AC_DEFUN([AX_HAVE_QT],
[
  AC_REQUIRE([AC_PROG_CXX])
  AC_REQUIRE([AC_PATH_X])
  AC_REQUIRE([AC_PATH_XTRA])

  AC_MSG_CHECKING(for Qt)

  AC_ARG_WITH([Qt-dir],
              AS_HELP_STRING([--with-Qt-dir=DIR],
                             [DIR is equal to $QTDIR if you have followed the
                              installation instructions of Trolltech. Header
                              files are in DIR/include, binary utilities are
                              in DIR/bin. The library is in DIR/lib, unless
                              --with-Qt-lib-dir is also set.]))
  AC_ARG_WITH([Qt-include-dir],
              AS_HELP_STRING([--with-Qt-include-dir=DIR],
                             [Qt header files are in DIR]))
  AC_ARG_WITH([Qt-bin-dir],
              AS_HELP_STRING([--with-Qt-bin-dir=DIR],
                             [Qt utilities such as moc and uic are in DIR]))
  AC_ARG_WITH([Qt-lib-dir],
              AS_HELP_STRING([--with-Qt-lib-dir=DIR],
                             [The Qt library is in DIR]))
  AC_ARG_WITH([Qt-lib],
              AS_HELP_STRING([--with-Qt-lib=LIB],
                             [Use -lLIB to link with the Qt library]))
  if test x"$with_Qt_dir" = x"no" ||
     test x"$with_Qt_include-dir" = x"no" ||
     test x"$with_Qt_bin_dir" = x"no" ||
     test x"$with_Qt_lib_dir" = x"no" ||
     test x"$with_Qt_lib" = x"no"; then
    # user disabled Qt. Leave cache alone.
    have_qt="User disabled Qt."
  else
    # "yes" is a bogus option
    if test x"$with_Qt_dir" = xyes; then
      with_Qt_dir=
    fi
    if test x"$with_Qt_include_dir" = xyes; then
      with_Qt_include_dir=
    fi
    if test x"$with_Qt_bin_dir" = xyes; then
      with_Qt_bin_dir=
    fi
    if test x"$with_Qt_lib_dir" = xyes; then
      with_Qt_lib_dir=
    fi
    if test x"$with_Qt_lib" = xyes; then
      with_Qt_lib=
    fi
    # No Qt unless we discover otherwise
    have_qt=no
    # Check whether we are requested to link with a specific version
    if test x"$with_Qt_lib" != x; then
      ax_qt_lib="$with_Qt_lib"
    fi
    # Check whether we were supplied with an answer already
    if test x"$with_Qt_dir" != x; then
      _AX_HAVE_QT_USE_QTDIR($with_Qt_dir)
    else
      # Use cached value or do search, starting with suggestions from
      # the command line
      AC_CACHE_VAL(ax_cv_have_qt,
      [
        # We are not given a solution and there is no cached value.
        ax_qt_dir=NO
        ax_qt_include_dir=NO
        ax_qt_lib_dir=NO
        if test x"$ax_qt_lib" = x; then
          ax_qt_lib=NO
        fi
        ## Look for header files ##
        if test x"$with_Qt_include_dir" != x; then
          ax_qt_include_dir="$with_Qt_include_dir"
        else
          _AX_HAVE_QT_FIND_INCLUDE
        fi
        _AX_HAVE_QT_INSERT([QT_CXXFLAGS], [-I"$ax_qt_include_dir"])

        # Are these headers located in a traditional Trolltech installation?
        # That would be $ax_qt_include_dir stripped from its last element:
        _AX_HAVE_QT_CHECK_FOR_QTDIR(`dirname $ax_qt_include_dir`, [
          _AX_HAVE_QT_USE_QTDIR(`dirname $ax_qt_include_dir`)
        ], [
          # There is no valid definition for $QTDIR as Trolltech likes to see it
          ax_qt_dir=
          ## Look for Qt library ##
          if test x"$with_Qt_lib_dir" != x; then
            ax_qt_lib_dir="$with_Qt_lib_dir"
            # Only look for lib if the user did not supply it already
            if test x"$ax_qt_lib" = xNO; then
              ax_qt_lib="`ls $ax_qt_lib_dir/libqt* | sed -n 1p |
                           sed s@$ax_qt_lib_dir/lib@@ | [sed s@[.].*@@]`"
            fi
            # This blows away any previous QT_LIBS setting.
            QT_LIBS="-L$ax_qt_lib_dir -l$ax_qt_lib $X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS"
          else
            if test x"$ax_qt_lib" = xNO; then
              ax_qt_lib=qt
            fi
            for ax_possible_module in QtGui QtCore qt qt-mt qt-gl; do
              _AX_HAVE_QT_ADD_MODULE($ax_possible_module,[
                ax_qt_lib=$ax_possible_module
                ax_qt_lib_dir=
              ],[
                echo "Non-critical error, please neglect the above." >&AS_MESSAGE_LOG_FD
              ])
            done
          fi dnl $with_Qt_lib_dir was not given
        ])
        if test "$ax_qt_dir" = NO ||
           test "$ax_qt_include_dir" = NO ||
           test "$ax_qt_lib_dir" = NO ||
           test "$ax_qt_lib" = NO; then
          # Problem with finding complete Qt.  Cache the known absence of Qt.
          ax_cv_have_qt="have_qt=no"
        else
          # Record where we found Qt for the cache.
          ax_cv_have_qt="have_qt=yes                 \
                       ax_qt_dir=\"$ax_qt_dir\"          \
               ax_qt_include_dir=\"$ax_qt_include_dir\"  \
               QT_CXXFLAGS=\"$QT_CXXFLAGS\"        \
                   ax_qt_bin_dir=\"$ax_qt_bin_dir\"      \
                      QT_LIBS=\"$QT_LIBS\""
        fi
      ])dnl
      eval "$ax_cv_have_qt"
    fi # all $ax_qt_* are set
  fi   # $have_qt reflects the system status
  if test x"$have_qt" = xyes; then
    QT_DIR="$ax_qt_dir"
    # If ax_qt_dir is defined, utilities are expected to be in the
    # bin subdirectory
    if test x"$with_Qt_bin_dir" != x; then
      ax_qt_bin_dir=$with_Qt_bin_dir
    else
      if test x"$ax_qt_dir" != x; then
        ax_qt_bin_dir="$ax_qt_dir/bin"
      fi
    fi
    if test x"$ax_qt_bin_dir" != x; then
      if test -x "$ax_qt_bin_dir/uic"; then
        QT_UIC="$ax_qt_bin_dir/uic"
      else
        # Old versions of Qt don't have uic
        QT_UIC=
      fi
      QT_MOC="$ax_qt_bin_dir/moc"
      QT_LRELEASE="$ax_qt_bin_dir/lrelease"
      QT_LUPDATE="$ax_qt_bin_dir/lupdate"
    else
      # Last possibility is that they are in $PATH
      if test x"`which moc`" != x; then
        # Check if it's in the PATH
        QT_UIC="`which uic`"
        QT_MOC="`which moc`"
        QT_LRELEASE="`which lrelease`"
        QT_LUPDATE="`which lupdate`"
      else
        # Check if it's been packaged with a -qt4 suffix
        QT_MOC="`which moc-qt4`"
        QT_UIC="`which uic-qt4`"
        QT_LRELEASE="`which lrelease-qt4`"
        QT_LUPDATE="`which lupdate-qt4`"
      fi
    fi
    # All variables are defined, report the result
    AC_MSG_RESULT([$have_qt:
    QT_CXXFLAGS=$QT_CXXFLAGS
    QT_DIR=$QT_DIR
    QT_LIBS=$QT_LIBS
    QT_UIC=$QT_UIC
    QT_MOC=$QT_MOC
    QT_LRELEASE=$QT_LRELEASE
    QT_LUPDATE=$QT_LUPDATE])
  else
    # Qt was not found
    QT_CXXFLAGS=
    QT_DIR=
    QT_LIBS=
    QT_UIC=
    QT_MOC=
    QT_LRELEASE=
    QT_LUPDATE=
    AC_MSG_RESULT($have_qt)
  fi
  AC_SUBST(QT_CXXFLAGS)
  AC_SUBST(QT_DIR)
  AC_SUBST(QT_LIBS)
  AC_SUBST(QT_UIC)
  AC_SUBST(QT_MOC)
  AC_SUBST(QT_LRELEASE)
  AC_SUBST(QT_LUPDATE)

  # Ensure our Qt configuration actually works
  if test x"$have_qt" = xyes; then
    _AX_HAVE_QT_VERIFY_TOOLCHAIN
  fi
])

dnl Iterate over a set of common directories, executing specified shell script for each entry.
dnl
dnl The first argument specifies the variable name of a given directory. This name should be used
dnl in the specified shell script.
dnl
dnl The second argument consists of shell script that will be executed for each entry. If the shell
dnl script calls "break", then iteration will immediately stop.
dnl
dnl The third argument consists of any extra directories that will be iterated.
AC_DEFUN([_AX_HAVE_QT_FOR_EACH_DIR],[
  for ax_for_each_dir_root in $3 \
    "${QTDIR}" \
    /lib64 \
    /lib \
    /usr \
    /usr/include \
    /usr/lib64 \
    /usr/lib \
    /usr/local \
    /opt \
    /Developer;
  do
    for $1 in \
      "$ax_for_each_dir_root" \
      `ls -dr $ax_dir_root/qt* 2>/dev/null` \
      `ls -dr $ax_dir_root/Qt* 2>/dev/null`;
    do
      ax_continue_flag=
      $2
      # Detect if we broke out of the for-loop using this flag
      ax_continue_flag=yes
    done
    if test x"$ax_continue_flag" != xyes; then
      break;
    fi;
  done
])

dnl Add a parameter to the specified variable.
dnl
dnl The first parameter is the name of the variable that will be modified.
dnl The second parameter is the parameter that will be added. Multiple parameters
dnl are allowed.
dnl
dnl The third parameter will, if "yes", force the variable to be added to the front, rather
dnl than the back of the specified variable.
AC_DEFUN([_AX_HAVE_QT_INSERT], [
  ax_target_variable=$1
  ax_all_inserted_values=$2
  ax_insert_to_front=$3
  ax_inserted_variable_list=
  for ax_one_inserted_value in $2; do
    ax_do_insertion=yes
    for ax_this_value in $$1; do
      if test x"$ax_this_value" = x"$ax_one_inserted_value"; then
        # Value is already present, so no need to insert it again
        ax_do_insertion=
        break
      fi
    done
    if test x"$ax_do_insertion" = xyes; then
      ax_inserted_variable_list="$ax_inserted_variable_list $ax_one_inserted_value"
    fi
  done
  if test x"$ax_insert_to_front" = xyes; then
    eval "$ax_target_variable=\"$ax_inserted_variable_list "'$'"$ax_target_variable\""
  else
    eval "$ax_target_variable=\""'$'"$ax_target_variable $ax_inserted_variable_list\""
  fi;
])dnl _AX_HAVE_QT_INSERT

dnl Check if the specified directory is a traditional Qt directory, as provided
dnl by Trolltech.
dnl
dnl The first argument must be the path of the canonical Qt installation.
dnl
dnl The second and third arguments optionally specify any shell script that will be
dnl run on the success or failure, respectively, of this test.
AC_DEFUN([_AX_HAVE_QT_CHECK_FOR_QTDIR], [
  ax_qt_dir_candidate=$1
  if (test -x $ax_qt_dir_candidate/bin/moc) &&
     ((ls $ax_qt_dir_candidate/lib/libqt* > /dev/null 2>/dev/null) ||
      (ls $ax_qt_dir_candidate/lib64/libqt* > /dev/null 2>/dev/null) ||
      (ls $ax_qt_dir_candidate/lib/libQt* > /dev/null 2>/dev/null) ||
      (ls $ax_qt_dir_candidate/lib64/libQt* > /dev/null 2>/dev/null)); then
    :
    $2
  else
    :
    $3
  fi;
])

dnl Force Autoconf to use the specified directory as the canonical Qt installation.
dnl Where applicable, these contents will be preferred over external ones.
AC_DEFUN([_AX_HAVE_QT_USE_QTDIR], [
  ax_qt_dir="$1"
  _AX_HAVE_QT_CHECK_FOR_QTDIR($ax_qt_dir,,[
    AC_MSG_WARN([Specified Qt directory is not actually a Qt directory])
  ])
  have_qt=yes
  ax_qt_include_dir="$ax_qt_dir/include"
  ax_qt_bin_dir="$ax_qt_dir/bin"
  ax_qt_lib_dir="$ax_qt_dir/lib"
  if (test -d $ax_qt_dir/lib64); then
    ax_qt_lib_dir="$ax_qt_dir/lib64"
  else
    ax_qt_lib_dir="$ax_qt_dir/lib"
  fi
  # Only search for the lib if the user did not define one already
  if test x"$ax_qt_lib" = x; then
    ax_qt_lib="`ls $ax_qt_lib_dir/libqt* | sed -n 1p |
                 sed s@$ax_qt_lib_dir/lib@@ | [sed s@[.].*@@]`"
  fi
  QT_LIBS="-L$ax_qt_lib_dir -l$ax_qt_lib $X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS"
])

dnl Find the legacy include directory for Qt. While this is still used for modern
dnl versions of Qt, it is preferable to include the module header directories
dnl themselves.
dnl
dnl This macro sets the following variables:
dnl   ax_qt_include_dir - the path believed to contain Qt's header files
dnl
AC_DEFUN([_AX_HAVE_QT_FIND_INCLUDE], [
  # The following header file is expected to define QT_VERSION.
  qt_direct_test_header=qglobal.h
  # Look for the header file in a standard set of common directories.
  ax_prev_ver=0
  _AX_HAVE_QT_FOR_EACH_DIR([ax_dir_root], [
    for ax_dir in $ax_dir_root $ax_dir_root/include; do
      if test -r "$ax_dir/$qt_direct_test_header"; then
        # Check if this directory contains a newer library than our
        # previous candidate.
        ax_this_ver=`sed -nre 's/^[ ]*#define[ ]+QT_VERSION[ ]+//p' \
          $ax_dir/$qt_direct_test_header`
        if expr $ax_this_ver '>' $ax_prev_ver > /dev/null; then
          ax_qt_include_dir=$ax_dir
          ax_prev_ver=$ax_this_ver
        fi
      fi
    done
  ])
])dnl _AX_HAVE_QT_FIND_INCLUDE

dnl Ensure the specified module is available. If so, QT_LIBS and QT_CXXFLAGS
dnl will be updated with the required dependencies.
dnl
dnl The first argument must be the name of the module.
dnl
dnl The second and third arguments consist of shell script that will be run on
dnl success or failure, respectively,  of this test.
AC_DEFUN([AX_HAVE_QT_MODULE], [
  ax_qt_added_module=$1
  ax_qt_module_include_dir=
  # Find the include directory first
  ax_qt_header_name=
  ax_qt_module_CXXFLAGS=
  case "$ax_qt_added_module" in
    qt-mt)
      ax_qt_header_name="qglobal.h"
      ax_qt_module_CXXFLAGS="$ax_qt_module_CXXFLAGS -DQT_THREAD_SUPPORT" ;;
    qt*) ax_qt_header_name="qglobal.h" ;;
    QtCore) ax_qt_header_name="QCoreApplcation" ;;
    QtGui) ax_qt_header_name="QApplication" ;;
    QtOpenGL) ax_qt_header_name="QGLWidget" ;;
    QtSql) ax_qt_header_name="QSqlDatabase" ;;
    QtXml) ax_qt_header_name="QXmlSimpleReader" ;;
    QtTest) ax_qt_header_name="QTestEventList" ;;
    QtNetwork) ax_qt_header_name="QLocalSocket" ;;
  esac;
  _AX_HAVE_QT_FOR_EACH_DIR([ax_dir_root], [
    for ax_dir in $ax_dir_root $ax_dir_root/include; do
      if test -r "$ax_dir/$ax_qt_header_name"; then
        ax_qt_module_include_dir="$ax_dir"
        break;
      fi;
    done;
    if test x"$ax_qt_module_include_dir" != x; then
      break;
    fi
  ])
  if test x"$ax_qt_include_dir" != x; then
    ax_qt_module_CXXFLAGS="$ax_qt_module_CXXFLAGS -I$ax_qt_include_dir";
  fi
  if test x"$ax_qt_module_include_dir" != x; then
    ax_qt_module_CXXFLAGS="$ax_qt_module_CXXFLAGS -I$ax_qt_module_include_dir";
  fi
  # First, attempt without any explicit library path
  _AX_HAVE_QT_CHECK_MODULE($ax_qt_added_module,[],["$QT_CXXFLAGS $ax_qt_module_CXXFLAGS"], [
    _AX_HAVE_QT_INSERT([QT_CXXFLAGS], [$ax_qt_module_CXXFLAGS])
    _AX_HAVE_QT_INSERT([QT_LIBS], [-l$ax_qt_added_module])
    $2
    :
  ],[
    ax_found_a_good_dir=no
    _AX_HAVE_QT_FOR_EACH_DIR([ax_dir],[
      if ls $ax_dir/lib$ax_qt_added_module* >/dev/null 2>/dev/null; then
        _AX_HAVE_QT_CHECK_MODULE($ax_qt_added_module,["-L$ax_dir"],["$QT_CXXFLAGS $ax_qt_module_CXXFLAGS"],[
          _AX_HAVE_QT_INSERT([QT_CXXFLAGS], [$ax_qt_module_CXXFLAGS])
          _AX_HAVE_QT_INSERT([QT_LIBS], [-L$ax_dir -l$ax_qt_added_module])
          ax_found_a_good_dir=yes
          $2
          break;
        ])
      fi
    ])
    if test x"$ax_found_a_good_dir" != xyes; then
      # No luck adding this module
      $3
      :
    fi
  ])
])dnl _AX_HAVE_QT_ADD_MODULE

dnl Check for the specified Qt module.
dnl
dnl The second and third arguments will specify and LIBS and CXXFLAGS,
dnl respectively, that will be used during testing.
dnl
dnl The fourth and fifth arguments consist of shell script that will be
dnl run on success or failure of this test.
AC_DEFUN([_AX_HAVE_QT_CHECK_MODULE], [
  ax_save_LIBS="$LIBS"
  ax_save_CXXFLAGS="$CXXFLAGS"
  ax_qt_module_lib=$1
  ax_qt_module_LIBS=$2
  ax_qt_module_CXXFLAGS=$3
  CXXFLAGS=
  LIBS=
  qt_direct_test_header=
  qt_direct_test_main=
  case "$ax_qt_module_lib" in
    qt-mt)
      LIBS="$X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS"
      CXXFLAGS="$CXXFLAGS -DQT_THREAD_SUPPORT"
      qt_direct_test_header=QApplication
      qt_direct_test_main="
        int argc;
        char ** argv;
        QApplication app (argc,argv);
      "
      ;;
    qt|qt-gl)
      LIBS="$X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS"
      qt_direct_test_header=QApplication
      qt_direct_test_main="
        int argc;
        char ** argv;
        QApplication app (argc,argv);
      "
      ;;
    QtCore)
      qt_direct_test_header=QCoreApplication
      qt_direct_test_main="
        int argc;
        char ** argv;
        QCoreApplication app (argc,argv);
      "
      ;;
    QtGui)
      LIBS="$X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS -lQtCore"
      qt_direct_test_header=QApplication
      qt_direct_test_main="
        int argc;
        char ** argv;
        QApplication app (argc,argv);
      "
      ;;
    QtOpenGL)
      LIBS="$X_PRE_LIBS $X_LIBS $X_EXTRA_LIBS -lQtCore -lQtGui"
      qt_direct_test_header="QApplication QGLWidget"
      qt_direct_test_main="
        int argc;
        char ** argv;
        QApplication app (argc,argv);
        QGLWidget widget;
      "
      ;;
    QtXml)
      LIBS="-lQtCore"
      qt_direct_test_header="QCoreApplication QXmlSimpleReader"
      qt_direct_test_main="
        int argc;
        char ** argv;
        QCoreApplication app (argc,argv);
        QXmlSimpleReader reader;
      "
      ;;
    QtTest)
      LIBS="-lQtCore"
      qt_direct_test_header="QCoreApplication QTestEventList"
      qt_direct_test_main="
        int argc;
        char ** argv;
        QCoreApplication app (argc,argv);
        QTestEventList eventList;
      "
      ;;
    QtSql)
      LIBS="-lQtCore"
      qt_direct_test_header="QCoreApplication QSqlDatabase"
      qt_direct_test_main="
        int argc;
        char ** argv;
        QCoreApplication app (argc,argv);
        QSqlDatabase db;
      "
      ;;
    QtNetwork)
      LIBS="-lQtCore"
      qt_direct_test_header="QCoreApplication QLocalSocket"
      qt_direct_test_main="
        int argc;
        char ** argv;
        QCoreApplication app (argc,argv);
        QLocalSocket socket;
      "
      ;;
  esac;
  CXXFLAGS="$ax_qt_module_CXXFLAGS $CXXFLAGS"
  LIBS="$ax_qt_module_LIBS -l$ax_qt_module_lib $LIBS"
  ax_module_include_statement=
  for ax_included in $qt_direct_test_header; do
    ax_module_include_statement="$ax_module_include_statement
      #include <$ax_included>"
  done
  if test x"$qt_direct_test_main" != x; then
    AC_LANG_PUSH([C++])
    AC_TRY_LINK([$ax_module_include_statement],
      $qt_direct_test_main,
    [
      LIBS="$ax_save_LIBS"
      CXXFLAGS="$ax_save_CXXFLAGS"
      # Successfully linked our test code.
      $4
      :
    ], [
      LIBS="$ax_save_LIBS"
      CXXFLAGS="$ax_save_CXXFLAGS"
      $5
      :
    ])
    AC_LANG_POP([C++])
  fi;
])

AC_DEFUN([_AX_HAVE_QT_VERIFY_TOOLCHAIN], [
  AC_MSG_CHECKING(correct functioning of Qt installation)
  AC_CACHE_VAL(ax_cv_qt_test_result,
  [
    cat > ax_qt_test.h << EOF
#include <QObject>
class Test : public QObject
{
Q_OBJECT
public:
Test() {}
~Test() {}
public slots:
void receive() {}
signals:
void send();
};
EOF

    cat > ax_qt_main.$ac_ext << EOF
#include "ax_qt_test.h"
#include <QApplication>
int main( int argc, char **argv )
{
QApplication app( argc, argv );
Test t;
QObject::connect( &t, SIGNAL(send()), &t, SLOT(receive()) );
}
EOF

    ax_cv_qt_test_result="failure"
    ax_try_1="$QT_MOC ax_qt_test.h -o moc_ax_qt_test.$ac_ext >/dev/null 2>/dev/null"
    AC_TRY_EVAL(ax_try_1)
    if test x"$ac_status" != x0; then
      echo "$ax_err_1" >&AS_MESSAGE_LOG_FD
      echo "configure: could not run $QT_MOC on:" >&AS_MESSAGE_LOG_FD
      cat ax_qt_test.h >&AS_MESSAGE_LOG_FD
    else
      ax_try_2="$CXX $QT_CXXFLAGS -c $CXXFLAGS -o moc_ax_qt_test.o moc_ax_qt_test.$ac_ext >/dev/null 2>/dev/null"
      AC_TRY_EVAL(ax_try_2)
      if test x"$ac_status" != x0; then
        echo "$ax_err_2" >&AS_MESSAGE_LOG_FD
        echo "configure: could not compile:" >&AS_MESSAGE_LOG_FD
        cat moc_ax_qt_test.$ac_ext >&AS_MESSAGE_LOG_FD
      else
        ax_try_3="$CXX $QT_CXXFLAGS -c $CXXFLAGS -o ax_qt_main.o ax_qt_main.$ac_ext >/dev/null 2>/dev/null"
        AC_TRY_EVAL(ax_try_3)
        if test x"$ac_status" != x0; then
          echo "$ax_err_3" >&AS_MESSAGE_LOG_FD
          echo "configure: could not compile:" >&AS_MESSAGE_LOG_FD
          cat ax_qt_main.$ac_ext >&AS_MESSAGE_LOG_FD
        else
          ax_try_4="$CXX -o ax_qt_main ax_qt_main.o moc_ax_qt_test.o $QT_LIBS $LIBS >/dev/null 2>/dev/null"
          AC_TRY_EVAL(ax_try_4)
          if test x"$ac_status" != x0; then
            echo "$ax_err_4" >&AS_MESSAGE_LOG_FD
          else
            ax_cv_qt_test_result="success"
          fi
        fi
      fi
    fi
  ])dnl AC_CACHE_VAL ax_cv_qt_test_result
  AC_MSG_RESULT([$ax_cv_qt_test_result])
  if test x"$ax_cv_qt_test_result" = "xfailure"; then
    AC_MSG_ERROR([Failed to find matching components of a complete
                Qt installation. Try using more options,
                see ./configure --help.])
  fi

  rm -f ax_qt_test.h moc_ax_qt_test.$ac_ext moc_ax_qt_test.o \
          ax_qt_main.$ac_ext ax_qt_main.o ax_qt_main
])
