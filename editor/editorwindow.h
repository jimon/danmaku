#pragma once

#include <QMainWindow>

namespace Ui {
class EditorWindow;
}

class EditorWindow : public QMainWindow
{
	Q_OBJECT

public:
	explicit EditorWindow(QWidget * parent = 0);
	~EditorWindow();

private slots:
	void on_actionNew_triggered();
	void on_actionOpen_triggered();
	void on_actionUndo_triggered();
	void on_actionRedo_triggered();
	void on_actionAdd_Slave_triggered();
	void on_actionRemove_Slave_triggered();
	void on_listWidget_currentRowChanged(int currentRow);
	void on_listWidget_currentTextChanged(const QString &currentText);
	void stuffChanged();

private:
	Ui::EditorWindow * ui;

	QString filename;
	size_t slave_index = 0;
	bool ignoreChanges = false;

	struct slave_t
	{
		char		name[32] = {0};
		float		start_time = 0.0f;
		float		end_time = 0.0f;
		float		distance = 32.0f;
		float		start_angle = 0.0f;
		float		angular_velocity = 0.0f;
		char		n_type[32] = {0};
		bool		n_directed = false;
		bool		n_omni = false;
		bool		n_omni_destroy = false;
		int32_t		n_bullet = 0;
		int32_t		n_omni_bullet = 0;
		uint32_t	n_bullet_count = 0;
		int32_t		n_bullet_velocity = 0;
		uint32_t	n_fire_rate = 0;
		uint32_t	n_fire_counter = 0;
		float		n_offset_angle = 0.0f;
		float		n_buble_radius = 0.0f;
		float		n_sin_a = 0.0f;
		float		n_sin_w = 0.0f;
		float		n_sin_c = 0.0f;
		float		n_spray_angle = 0.0f;
		bool		m_modifier = false;
		char		m_type[32] = {0};
		uint32_t	m_bullet = 0;
		int32_t		m_amount = 0;
	};

	slave_t slaves[1024];
};
