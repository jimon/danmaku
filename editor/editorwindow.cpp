#include "editorwindow.h"
#include "ui_editorwindow.h"
#include <QFileDialog>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonDocument>
#include <QDebug>
#include <QProcess>

// TODO undo-redo haven't quite worked
// because stuffChanged is called on every change
// but we need to do snapshots only when user ended editing

// schema driven editor anyone ?

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
	QObject::connect(ui->listWidget->itemDelegate(), SIGNAL(commitData(QWidget*)), this, SLOT(stuffChanged()));

	ui->startTimeSlider->setMinimum(0); ui->startTimeSlider->setMaximum(1000);
	ui->endTimeSlider->setMinimum(0); ui->endTimeSlider->setMaximum(1000);

	ui->distanceSlider->setMinimum(0); ui->distanceSlider->setMaximum(256);
	ui->startAngleSlider->setMinimum(0); ui->startAngleSlider->setMaximum(360);
	ui->angulerVelocitySlider->setMinimum(0); ui->angulerVelocitySlider->setMaximum(200); ui->angulerVelocitySlider->setProperty("scale", 10);

	ui->nBulletCount->setMinimum(0); ui->nBulletCount->setMaximum(400);
	ui->nBulletVelocity->setMinimum(-1000); ui->nBulletVelocity->setMaximum(1000); ui->nBulletVelocity->setProperty("scale", 10);
	ui->nOffsetAngle->setMinimum(0); ui->nOffsetAngle->setMaximum(360);
	ui->nBubleRadius->setMinimum(0); ui->nBubleRadius->setMaximum(400);
	ui->nSinA->setMinimum(0); ui->nSinA->setMaximum(1000); ui->nSinA->setProperty("scale", 10);
	ui->nSinW->setMinimum(0); ui->nSinW->setMaximum(1000); ui->nSinW->setProperty("scale", 10);
	ui->nSinCounter->setMinimum(0); ui->nSinCounter->setMaximum(100);
	ui->nSprayAngle->setMinimum(0); ui->nSprayAngle->setMaximum(360);
	ui->mAmount->setMinimum(-1500); ui->mAmount->setMaximum(1500); ui->mAmount->setProperty("scale", 50);

	ui->nFireRate->setMinimum(0); ui->nFireRate->setMaximum(500);
	ui->nFireCounter->setMinimum(0); ui->nFireCounter->setMaximum(500);

	ui->nBulletSpinbox->setMinimum(1);
	ui->nOmniSpinbox->setMinimum(1);
	ui->mBullet->setMinimum(1);

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

	//filename = "C:/work/danmaku/test.json";
	gameExe = "C:/work/danmaku/_edit.bat";
	//load();
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
	load();
}

void EditorWindow::on_actionUndo_triggered()
{
	if(snapshots.count())
	{
		snapshot_t current_snapshot;
		take_snapshot(current_snapshot);
		snapshots_redo.push(current_snapshot);

		snapshot_t snapshot = snapshots.pop();
		apply_snapshot(snapshot);
	}
}

void EditorWindow::on_actionRedo_triggered()
{
	if(snapshots_redo.count())
	{
		snapshot_t current_snapshot;
		take_snapshot(current_snapshot);
		snapshots.push(current_snapshot);

		snapshot_t snapshot = snapshots_redo.pop();
		apply_snapshot(snapshot);
	}
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
	slaves[row] = slave_t();
	strcpy_s(slaves[row].name, sizeof(slave_t::name), name.toLatin1().data());
	ignoreChanges = true;
	ui->listWidget->setCurrentRow(row);
	ignoreChanges = false;
	on_listWidget_currentRowChanged(row);
	save();
}

void EditorWindow::on_actionRemove_Slave_triggered()
{
	if(ui->listWidget->currentItem())
	{
		for(int i = ui->listWidget->currentRow(); i < ui->listWidget->count() - 1; ++i)
			slaves[i] = slaves[i + 1];
		delete ui->listWidget->currentItem();
		save();
		on_listWidget_currentRowChanged(ui->listWidget->currentRow());
	}
}

void EditorWindow::on_actionRun_triggered()
{
	QProcess game;
	game.startDetached(gameExe, QStringList() << QFileInfo(gameExe).dir().relativeFilePath(filename));
}

void EditorWindow::on_listWidget_currentRowChanged(int currentRow)
{
	if(ignoreChanges)
		return;
	if(currentRow < 0)
		return;

	int row = currentRow;

	ignoreChanges = true;

	#define _set_val(__slider, __value) \
	{ \
		bool ok = true; \
		float scale = (float)ui->__slider->property("scale").toInt(&ok); \
		if(!ok) \
			scale = 1.0f; \
		ui->__slider->setValue((int)((float)slaves[row].__value * scale)); \
	}

	_set_val(startTimeSlider, start_time);
	_set_val(endTimeSlider, end_time);
	_set_val(distanceSlider, distance);
	_set_val(startAngleSlider, start_angle);
	_set_val(angulerVelocitySlider, angular_velocity);
	_set_val(nBulletCount, n_bullet_count);
	_set_val(nBulletVelocity, n_bullet_velocity);
	_set_val(nFireRate, n_fire_rate);
	_set_val(nFireCounter, n_fire_counter);
	_set_val(nOffsetAngle, n_offset_angle);
	_set_val(nBubleRadius, n_buble_radius);
	_set_val(nSinA, n_sin_a);
	_set_val(nSinW, n_sin_w);
	_set_val(nSinCounter, n_sin_c);
	_set_val(nSprayAngle, n_spray_angle);
	_set_val(mAmount, m_amount);

	ui->nTypeCombo->setCurrentText(slaves[row].n_type);
	ui->mType->setCurrentText(slaves[row].m_type);

	ui->nOmniSpinbox->setValue(slaves[row].n_omni_bullet);
	ui->nBulletSpinbox->setValue(slaves[row].n_bullet);
	ui->mBullet->setValue(slaves[row].m_bullet);

	ui->nDirected->setChecked(slaves[row].n_directed);
	ui->nOmni->setChecked(slaves[row].n_omni);
	ui->nOmniDestroy->setChecked(slaves[row].n_omni_destroy);
	ui->modifierBox->setChecked(slaves[row].m_modifier);

	ui->tabWidget->setCurrentIndex(slaves[row].m_modifier ? 1 : 0);

	ignoreChanges = false;
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
		//snapshot_t snapshot;
		//take_snapshot(snapshot);
		//snapshots.push(snapshot);
		//snapshots_redo.clear();

		#define _read_val(__slider, __value) \
		{ \
			bool ok = true; \
			float scale = (float)ui->__slider->property("scale").toInt(&ok); \
			if(!ok) \
				scale = 1.0f; \
			slaves[row].__value = ((float)ui->__slider->value()) / scale; \
		}

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

		strcpy_s(slaves[row].n_type, sizeof(slave_t::n_type), ui->nTypeCombo->currentText().toLatin1().data());
		strcpy_s(slaves[row].m_type, sizeof(slave_t::m_type), ui->mType->currentText().toLatin1().data());

		slaves[row].n_omni_bullet = ui->nOmniSpinbox->value();
		slaves[row].n_bullet = ui->nBulletSpinbox->value();
		slaves[row].m_bullet = ui->mBullet->value();

		slaves[row].n_directed = ui->nDirected->isChecked();
		slaves[row].n_omni = ui->nOmni->isChecked();
		slaves[row].n_omni_destroy = ui->nOmniDestroy->isChecked();
		slaves[row].m_modifier = ui->modifierBox->isChecked();

		strcpy_s(slaves[row].name, sizeof(slave_t::name), ui->listWidget->currentItem()->text().toLatin1().data());

		save();
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
}

void EditorWindow::load()
{
	ui->listWidget->clear();

	QFile data(filename);
	if(data.open(QFile::ReadOnly))
	{
		QJsonDocument doc = QJsonDocument::fromJson(data.readAll());
		QJsonArray arr = doc.array();

		for(int i = 0; i < arr.count(); ++i)
		{
			slave_t slave;
			QJsonObject obj = arr[i].toObject();

			strcpy_s(slave.name, sizeof(slave_t::name), obj["name"].toString("unknown").toLatin1().data());

			slave.start_time = (float)obj["start"].toDouble();
			slave.end_time = (float)obj["end"].toDouble();
			slave.distance = (float)obj["distance"].toDouble();
			slave.start_angle = (float)obj["angle"].toDouble();
			slave.angular_velocity = (float)obj["velocity"].toDouble();

			if(obj.contains("mod"))
			{
				QJsonObject mod = obj["mod"].toObject();
				slave.m_modifier = true;
				strcpy_s(slave.m_type, sizeof(slave_t::m_type), mod["type"].toString("friction").toLatin1().data());
				slave.m_bullet = (uint32_t)mod["bullet"].toInt(1);
				slave.m_amount = (float)mod["amount"].toDouble();
			}

			if(obj.contains("fire"))
			{
				QJsonObject fire = obj["fire"].toObject();
				slave.m_modifier = false;
				strcpy_s(slave.n_type, sizeof(slave_t::n_type), fire["type"].toString("burst").toLatin1().data());
				slave.n_directed = fire["directed"].toBool();
				slave.n_bullet = (int32_t)fire["bullet"].toInt(1);
				slave.n_bullet_count = (uint32_t)fire["count"].toInt();
				slave.n_bullet_velocity = (float)fire["velocity"].toDouble();
				slave.n_fire_rate = (uint32_t)fire["rate"].toInt();
				slave.n_fire_counter = (uint32_t)fire["counter"].toInt();
				slave.n_offset_angle = (float)fire["offset"].toDouble();
				if(!strcmp(slave.n_type, "buble"))
					slave.n_buble_radius = (float)fire["radius"].toDouble();
				if(!strcmp(slave.n_type, "sinwave"))
				{
					slave.n_sin_a = (float)fire["sin_a"].toDouble();
					slave.n_sin_w = (float)fire["sin_w"].toDouble();
					slave.n_sin_c = (float)fire["sin_c"].toDouble();
				}
				if(!strcmp(slave.n_type, "spray"))
					slave.n_spray_angle = (float)fire["angle"].toDouble();
				if(fire["omni"].toInt() > 0)
				{
					slave.n_omni = true;
					slave.n_omni_bullet = (uint32_t)fire["omni"].toInt();
					slave.n_omni_destroy = fire["destroy"].toBool();
				}
			}

			slaves[i] = slave;
			ignoreChanges = true;

			QListWidgetItem * item = new QListWidgetItem(slave.name, ui->listWidget);
			item->setFlags(item->flags() | Qt::ItemIsEditable);
			ui->listWidget->addItem(item);

			ignoreChanges = false;
		}

		slave_index = arr.count();
	}
}

void EditorWindow::save()
{
	QVariantList output;
	for(int i = 0; i < ui->listWidget->count(); ++i)
	{
		QVariantMap slave;
		slave["name"] =		slaves[i].name;
		slave["start"] =	slaves[i].start_time;
		slave["end"] =		slaves[i].end_time;
		slave["distance"] =	slaves[i].distance;
		slave["angle"] =	slaves[i].start_angle;
		slave["velocity"] =	slaves[i].angular_velocity;

		if(slaves[i].m_modifier)
		{
			QVariantMap mod;
			mod["type"] =	slaves[i].m_type;
			mod["bullet"] =	slaves[i].m_bullet;
			mod["amount"] =	slaves[i].m_amount;
			slave["mod"] = mod;
		}
		else
		{
			QVariantMap fire;
			fire["type"] =			slaves[i].n_type;
			fire["directed"] =		slaves[i].n_directed;
			fire["bullet"] =		slaves[i].n_bullet;
			fire["count"] =			slaves[i].n_bullet_count;
			fire["velocity"] =		slaves[i].n_bullet_velocity;
			fire["rate"] =			slaves[i].n_fire_rate;
			fire["counter"] =		slaves[i].n_fire_counter;
			fire["offset"] =		slaves[i].n_offset_angle;
			if(!strcmp(slaves[i].n_type, "buble"))
				fire["radius"] =	slaves[i].n_buble_radius;
			if(!strcmp(slaves[i].n_type, "sinwave"))
			{
				fire["sin_a"] =		slaves[i].n_sin_a;
				fire["sin_w"] =		slaves[i].n_sin_w;
				fire["sin_c"] =		slaves[i].n_sin_c;
			}
			if(!strcmp(slaves[i].n_type, "spray"))
				fire["angle"] =		slaves[i].n_spray_angle;
			if(slaves[i].n_omni)
			{
				fire["omni"] =		slaves[i].n_omni_bullet;
				fire["destroy"] =	slaves[i].n_omni_destroy;
			}
			slave["fire"] = fire;
		}

		output.push_back(slave);
	}

	QFile data(filename);
	if(data.open(QFile::WriteOnly | QFile::Truncate))
		data.write(QJsonDocument(QJsonArray::fromVariantList(output)).toJson());
}

void EditorWindow::take_snapshot(EditorWindow::snapshot_t & snapshot)
{
	memcpy(snapshot.slaves, slaves, sizeof(slave_t) * 1024);
	snapshot.selection = ui->listWidget->currentRow();
	snapshot.count = ui->listWidget->count();
}

void EditorWindow::apply_snapshot(const EditorWindow::snapshot_t & snapshot)
{
	memcpy(slaves, snapshot.slaves, sizeof(slave_t) * 1024);

	ignoreChanges = true;
	ui->listWidget->clear();
	for(size_t i = 0; i < snapshot.count; ++i)
	{
		QListWidgetItem * item = new QListWidgetItem(slaves[i].name, ui->listWidget);
		item->setFlags(item->flags() | Qt::ItemIsEditable);
		ui->listWidget->addItem(item);
	}
	ignoreChanges = false;
	ui->listWidget->setCurrentRow(snapshot.selection);
	save();
}
