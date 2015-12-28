#include "editorwindow.h"
#include "ui_editorwindow.h"
#include <QFileDialog>

EditorWindow::EditorWindow(QWidget * parent)
	:QMainWindow(parent),
	ui(new Ui::EditorWindow)
{
	ui->setupUi(this);

	QObject::connect(ui->startTimeSlider, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->endTimeSlider, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->distanceSlider, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->startAngleSlider, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->angulerVelocitySlider, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nBulletCount, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nBulletVelocity, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nFireRate, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nFireCounter, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nOffsetAngle, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nBubleRadius, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nSinA, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nSinW, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nSinCounter, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nSprayAngle, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->mAmount, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->tabWidget, SIGNAL(currentChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nTypeCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->mType, SIGNAL(currentIndexChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nOmniSpinbox, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nBulletSpinbox, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->mBullet, SIGNAL(valueChanged(int)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nDirected, SIGNAL(toggled(bool)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nOmni, SIGNAL(toggled(bool)), this, SLOT(stuffChanged()));
	QObject::connect(ui->nOmniDestroy, SIGNAL(toggled(bool)), this, SLOT(stuffChanged()));
	QObject::connect(ui->modifierBox, SIGNAL(toggled(bool)), this, SLOT(stuffChanged()));

	/*
	QListWidget *listWidget;
	QTabWidget *tabWidget;
	QWidget *normalTab;
	QWidget *modTab;

	QComboBox *nTypeCombo;
	QComboBox *mType;

	QSpinBox *nOmniSpinbox;
	QSpinBox *nBulletSpinbox;
	QSpinBox *mBullet;
	QCheckBox *nDirected;
	QCheckBox *nOmni;
	QCheckBox *nOmniDestroy;
	QCheckBox *modifierBox;

	QSlider *startTimeSlider;
	QSlider *endTimeSlider;
	QSlider *distanceSlider;
	QSlider *startAngleSlider;
	QSlider *angulerVelocitySlider;
	QSlider *nBulletCount;
	QSlider *nBulletVelocity;
	QSlider *nFireRate;
	QSlider *nFireCounter;
	QSlider *nOffsetAngle;
	QSlider *nBubleRadius;
	QSlider *nSinA;
	QSlider *nSinW;
	QSlider *nSinCounter;
	QSlider *nSprayAngle;
	QSlider *mAmount;
	*/

	// TODO

	filename = "test.json";
	on_actionAdd_Slave_triggered();
}

EditorWindow::~EditorWindow()
{
	delete ui;
}

void EditorWindow::on_actionNew_triggered()
{
	filename = QFileDialog::getSaveFileName(this, "New file", "", "*.json");
}

void EditorWindow::on_actionOpen_triggered()
{
	filename = QFileDialog::getOpenFileName(this, "Open file", "", "*.json");
	// TODO
}

void EditorWindow::on_actionUndo_triggered()
{
	// TODO
}

void EditorWindow::on_actionRedo_triggered()
{
	// TODO
}

void EditorWindow::on_actionAdd_Slave_triggered()
{
	if(ui->listWidget->count() > 1024) // not realistic
		return;
	if(!filename.length())
		on_actionNew_triggered();
	QString name = QString("slave_%1").arg(++slave_index);
	QListWidgetItem * item = new QListWidgetItem(name, ui->listWidget);
	item->setFlags(item->flags() | Qt::ItemIsEditable);
	ui->listWidget->addItem(item);
	int row = ui->listWidget->count() - 1;
	ui->listWidget->setCurrentRow(row);
	strcpy_s(slaves[row].name, sizeof(slaves[row].name), name.toLatin1().data());
	ignoreChanges = true;
	stuffChanged();
	ignoreChanges = false;
}

void EditorWindow::on_actionRemove_Slave_triggered()
{
	// TODO
	if(ui->listWidget->currentItem())
		delete ui->listWidget->currentItem();
	stuffChanged();
}

void EditorWindow::on_listWidget_currentRowChanged(int currentRow)
{
	if(ignoreChanges)
		return;
	// TODO
}

void EditorWindow::on_listWidget_currentTextChanged(const QString &currentText)
{
	if(ignoreChanges)
		return;
	// TODO
}

void EditorWindow::stuffChanged()
{
	setWindowTitle(QString("Danmaku editor : %1").arg(filename));
	ui->tabWidget->setEnabled(ui->listWidget->currentRow() >= 0);
	if(ui->listWidget->currentRow() < 0)
		return;

	int row = ui->listWidget->currentRow();
	if(ui->tabWidget->currentWidget() == ui->normalTab)
	{
		ui->nBubleRadius->setEnabled(ui->nTypeCombo->currentText() == "buble");
		ui->nSinA->setEnabled(ui->nTypeCombo->currentText() == "sinwave");
		ui->nSinW->setEnabled(ui->nTypeCombo->currentText() == "sinwave");
		ui->nSinCounter->setEnabled(ui->nTypeCombo->currentText() == "sinwave");
		ui->nSprayAngle->setEnabled(ui->nTypeCombo->currentText() == "spray");
	}

	if(!ignoreChanges)
	{
		#define _read_val(__slider, __value) \
			slaves[row].__value = ui->__slider->value();

		_read_val(startTimeSlider, start_time);
		_read_val(endTimeSlider, end_time);
		_read_val(distanceSlider, distance);
		_read_val(startAngleSlider, start_angle);
		_read_val(angulerVelocitySlider, angular_velocity);
		_read_val(nBulletCount, n_bullet_count);
		_read_val(nBulletVelocity, n_bullet_velocity);
		_read_val(nFireRate, n_fire_rate);
		_read_val(nFireCounter, n_fire_counter);
		_read_val(nOffsetAngle, n_offset_angle);
		_read_val(nBubleRadius, n_buble_radius);
		_read_val(nSinA, n_sin_a);
		_read_val(nSinW, n_sin_w);
		_read_val(nSinCounter, n_sin_c);
		_read_val(nSprayAngle, n_spray_angle);
		_read_val(mAmount, m_amount);
	}

	#define _set_tooltip(__slider, __value) \
		ui->__slider->setToolTip(QString("val : %1").arg(slaves[row].__value));
	_set_tooltip(startTimeSlider, start_time);
	_set_tooltip(endTimeSlider, end_time);
	_set_tooltip(distanceSlider, distance);
	_set_tooltip(startAngleSlider, start_angle);
	_set_tooltip(angulerVelocitySlider, angular_velocity);
	_set_tooltip(nBulletCount, n_bullet_count);
	_set_tooltip(nBulletVelocity, n_bullet_velocity);
	_set_tooltip(nFireRate, n_fire_rate);
	_set_tooltip(nFireCounter, n_fire_counter);
	_set_tooltip(nOffsetAngle, n_offset_angle);
	_set_tooltip(nBubleRadius, n_buble_radius);
	_set_tooltip(nSinA, n_sin_a);
	_set_tooltip(nSinW, n_sin_w);
	_set_tooltip(nSinCounter, n_sin_c);
	_set_tooltip(nSprayAngle, n_spray_angle);
	_set_tooltip(mAmount, m_amount);

	/*
	QSlider *startTimeSlider;
	QSlider *endTimeSlider;
	QSlider *distanceSlider;
	QSlider *startAngleSlider;
	QSlider *angulerVelocitySlider;
	QSlider *nBulletCount;
	QSlider *nBulletVelocity;
	QSlider *nFireRate;
	QSlider *nFireCounter;
	QSlider *nOffsetAngle;
	QSlider *nBubleRadius;
	QSlider *nSinA;
	QSlider *nSinW;
	QSlider *nSinCounter;
	QSlider *nSprayAngle;
	QSlider *mAmount;*/


	// TODO

}

