
import tango.io.Stdout;
import dynamin.all_core;
import dynamin.all_painting;
import dynamin.all_gui;

// cover:
// Buttons, Clipboard, cairo, Console,
// Mouse events, Key events, switching themes, menus, tool bars, layout,
// Scrollable

// only build with a console

// Mouse (events)
// have a container inside a container
// show all mouseEnter, mouseLeave
// have a blue dot move with mouseMove, red dot with mouseDragged

// Painting tabs inside of tabs
// have a star that follows the mouse
// have an animated progress circle

int getTimeGranularity() {
	long time = Environment.runningTime;
	int gran = 0;
	for(int i = 0; i < 2; ++i) {
		while(Environment.runningTime == time) {
		}
		gran = max(gran, cast(int)(Environment.runningTime-time));
		time = Environment.runningTime;
	}
	return gran;
}

class ButtonPanel : Container {
	Button dButton;
	this() {
		Button b;
		b = new Button;
		b.text = "Normal Button :|";
		b.location = [5, 5];
		b.size = [120, 23];
		add(b);

		b = new Button;
		b.text = "Colored Button :)";
		b.location = [5, 33];
		b.size = [120, 23];
		b.foreColor = Color.Blue;
		add(b);

		dButton = new Button;
		dButton.text = "Disabled Button :(";
		dButton.location = [5, 61];
		dButton.size = [120, 23];
		//dButton.enabled = false;
		add(dButton);

		b = new Button;
		b.text = "Toggle Disabled";
		b.location = [5, 89];
		b.size = [120, 23];
		b.clicked += &toggleButtonEnabled;
		add(b);

	}
	void toggleButtonEnabled() {
		//dButton.enabled = !dButton.enabled;
	}
}
class LargePane : Container {
	this() { backColor = Color.CornflowerBlue; }
	override bool elasticX() { return false; }
	override bool elasticY() { return false; }
	override Size bestSize() {
		return Size(300, 169);
	}
}
class ShowcaseNotebook : Notebook {
	this() {
		void addPage(string label, Container content) {
			auto page = new TabPage;
			page.text = label;
			page.content = content;
			tabPages.add(page);
		}
		addPage("Window", getWindowPanel());
		addPage("Buttons", new ButtonPanel);
		addPage("File Dialogs", getFileDialogsPanel());
		addPage("Cursors", getCursorsPanel());
	}
	//{{{ window
	RadioButton noneRadio;
	RadioButton normalRadio;
	RadioButton dialogRadio;
	RadioButton toolRadio;
	CheckBox resizableCheck;
	CheckBox snapCheck;
	Window snapWindow;
	RadioButton topLeftRadio;
	RadioButton topRadio;
	RadioButton topRightRadio;
	RadioButton leftRadio;
	RadioButton centerRadio;
	RadioButton rightRadio;
	RadioButton bottomLeftRadio;
	RadioButton bottomRadio;
	RadioButton bottomRightRadio;
	Container getWindowPanel() {
		auto styleLabel = new Label("Border style:");
		noneRadio = new RadioButton("None");
		noneRadio.checkedChanged += &styleRadioChanged;
		normalRadio = new RadioButton("Normal");
		normalRadio.checked = true;
		normalRadio.checkedChanged += &styleRadioChanged;
		dialogRadio = new RadioButton("Dialog");
		dialogRadio.checkedChanged += &styleRadioChanged;
		toolRadio = new RadioButton("Tool");
		toolRadio.checkedChanged += &styleRadioChanged;
		setGroup(1, noneRadio, normalRadio, dialogRadio, toolRadio);

		auto stateLabel = new Label("State:");
		auto normalButton = new Button("Normal");
		normalButton.clicked += &normalButtonClicked;
		auto minimizeButton = new Button("Minimize");
		minimizeButton.clicked += &minimizeButtonClicked;
		auto maximizeButton = new Button("Maximize");
		maximizeButton.clicked += &maximizeButtonClicked;

		resizableCheck = new CheckBox("Resizable");
		resizableCheck.checked = true;
		resizableCheck.checkedChanged += &resizableCheckClicked;

		snapCheck = new CheckBox("Snap window");
		snapCheck.checkedChanged += &snapCheckChanged;
		snapWindow = new Window("Snap to me");
		snapWindow.size = Size(400, 225);
		snapWindow.position = Position.Center;
		snapWindow.moved += &snapWindowChanged;
		snapWindow.resized += &snapWindowChanged;
		snapWindow.visibleChanged += &snapWindowVisibleChanged;

		auto posLabel = new Label("Position:");
		topLeftRadio = new RadioButton("TopLeft");
		topLeftRadio.checkedChanged += &positionRadioChanged;
		topRadio = new RadioButton("Top");
		topRadio.checkedChanged += &positionRadioChanged;
		topRightRadio = new RadioButton("TopRight");
		topRightRadio.checkedChanged += &positionRadioChanged;
		leftRadio = new RadioButton("Left");
		leftRadio.checkedChanged += &positionRadioChanged;
		centerRadio = new RadioButton("Center");
		centerRadio.checked = true;
		centerRadio.checkedChanged += &positionRadioChanged;
		rightRadio = new RadioButton("Right");
		rightRadio.checkedChanged += &positionRadioChanged;
		bottomLeftRadio = new RadioButton("BottomLeft");
		bottomLeftRadio.checkedChanged += &positionRadioChanged;
		bottomRadio = new RadioButton("Bottom");
		bottomRadio.checkedChanged += &positionRadioChanged;
		bottomRightRadio = new RadioButton("BottomRight");
		bottomRightRadio.checkedChanged += &positionRadioChanged;
		setGroup(2, topLeftRadio, topRadio, topRightRadio,
			leftRadio, centerRadio, rightRadio,
			bottomLeftRadio, bottomRadio, bottomRightRadio);

		return mixin(createLayout(`H(
			V(T[2](
				styleLabel V(noneRadio normalRadio dialogRadio toolRadio)
				stateLabel V(normalButton minimizeButton maximizeButton))
			resizableCheck snapCheck)
			T[2](posLabel V(topLeftRadio topRadio topRightRadio
				leftRadio centerRadio rightRadio
				bottomLeftRadio bottomRadio bottomRightRadio))
			)`));
	}
	void styleRadioChanged() {
		if(noneRadio.checked)
			(cast(Window)getTopLevel()).borderStyle = WindowBorderStyle.None;
		else if(normalRadio.checked)
			(cast(Window)getTopLevel()).borderStyle = WindowBorderStyle.Normal;
		else if(dialogRadio.checked)
			(cast(Window)getTopLevel()).borderStyle = WindowBorderStyle.Dialog;
		else if(toolRadio.checked)
			(cast(Window)getTopLevel()).borderStyle = WindowBorderStyle.Tool;
	}
	void normalButtonClicked() {
		(cast(Window)getTopLevel()).state = WindowState.Normal;
	}
	void minimizeButtonClicked() {
		(cast(Window)getTopLevel()).state = WindowState.Minimized;
	}
	void maximizeButtonClicked() {
		(cast(Window)getTopLevel()).state = WindowState.Maximized;
	}
	void resizableCheckClicked() {
		(cast(Window)getTopLevel()).resizable = resizableCheck.checked;
	}
	void snapCheckChanged() {
		snapWindow.visible = snapCheck.checked;
		auto win = cast(Window)getTopLevel();
		if(snapCheck.checked)
			win.snapRect = snapWindow.location + snapWindow.size;
		else
			win.snapRects = null;
	}
	void snapWindowChanged() {
		if(!snapWindow.visible)
			return;
		(cast(Window)getTopLevel()).snapRect =
			snapWindow.location + snapWindow.size;
	}
	void snapWindowVisibleChanged() {
		snapCheck.checked = snapWindow.visible;
	}
	void positionRadioChanged() {
		auto win = cast(Window)getTopLevel();
		if(topLeftRadio.checked)
			win.position = Position.TopLeft;
		else if(topRadio.checked)
			win.position = Position.Top;
		else if(topRightRadio.checked)
			win.position = Position.TopRight;
		else if(leftRadio.checked)
			win.position = Position.Left;
		else if(centerRadio.checked)
			win.position = Position.Center;
		else if(rightRadio.checked)
			win.position = Position.Right;
		else if(bottomLeftRadio.checked)
			win.position = Position.BottomLeft;
		else if(bottomRadio.checked)
			win.position = Position.Bottom;
		else if(bottomRightRadio.checked)
			win.position = Position.BottomRight;
	}
	//}}}

	//{{{ cursors
	Container cursorsEx;
	Container getCursorsPanel() {
		cursorsEx = new LargePane;

		auto noneRadio = new RadioButton("None");
		noneRadio.checkedChanged += &noneClicked;
		auto arrowRadio = new RadioButton("Arrow");
		arrowRadio.checked = true;
		arrowRadio.checkedChanged += &arrowClicked;
		auto waitArrowRadio = new RadioButton("WaitArrow");
		waitArrowRadio.checkedChanged += &waitArrowClicked;
		auto waitRadio = new RadioButton("Wait");
		waitRadio.checkedChanged += &waitClicked;
		auto textRadio = new RadioButton("Text");
		textRadio.checkedChanged += &textClicked;
		auto handRadio = new RadioButton("Hand");
		handRadio.checkedChanged += &handClicked;
		auto moveRadio = new RadioButton("Move");
		moveRadio.checkedChanged += &moveClicked;
		auto resizeHorizRadio = new RadioButton("ResizeHoriz");
		resizeHorizRadio.checkedChanged += &resizeHorizClicked;
		auto resizeVertRadio = new RadioButton("ResizeVert");
		resizeVertRadio.checkedChanged += &resizeVertClicked;
		auto resizeBackslashRadio = new RadioButton("ResizeBackslash");
		resizeBackslashRadio.checkedChanged += &resizeBackslashClicked;
		auto resizeSlashRadio = new RadioButton("ResizeSlash");
		resizeSlashRadio.checkedChanged += &resizeSlashClicked;
		auto dragRadio = new RadioButton("Drag");
		dragRadio.checkedChanged += &dragClicked;
		auto invalidDragRadio = new RadioButton("InvalidDrag");
		invalidDragRadio.checkedChanged += &invalidDragClicked;
		auto reversedArrowRadio = new RadioButton("ReversedArrow");
		reversedArrowRadio.checkedChanged += &reversedArrowClicked;
		auto crosshairRadio = new RadioButton("Crosshair");
		crosshairRadio.checkedChanged += &crosshairClicked;

		return mixin(createLayout(`V( H( * cursorsEx * ) H( *
			V(noneRadio arrowRadio waitArrowRadio waitRadio textRadio)
			V(handRadio moveRadio resizeHorizRadio resizeVertRadio resizeBackslashRadio)
			V(resizeSlashRadio dragRadio invalidDragRadio reversedArrowRadio crosshairRadio)
			* ))`));
	}
	void noneClicked() {
		cursorsEx.cursor = Cursor.None;
	}
	void arrowClicked() {
		cursorsEx.cursor = Cursor.Arrow;
	}
	void waitArrowClicked() {
		cursorsEx.cursor = Cursor.WaitArrow;
	}
	void waitClicked() {
		cursorsEx.cursor = Cursor.Wait;
	}
	void textClicked() {
		cursorsEx.cursor = Cursor.Text;
	}
	void handClicked() {
		cursorsEx.cursor = Cursor.Hand;
	}
	void moveClicked() {
		cursorsEx.cursor = Cursor.Move;
	}
	void resizeHorizClicked() {
		cursorsEx.cursor = Cursor.ResizeHoriz;
	}
	void resizeVertClicked() {
		cursorsEx.cursor = Cursor.ResizeVert;
	}
	void resizeBackslashClicked() {
		cursorsEx.cursor = Cursor.ResizeBackslash;
	}
	void resizeSlashClicked() {
		cursorsEx.cursor = Cursor.ResizeSlash;
	}
	void dragClicked() {
		cursorsEx.cursor = Cursor.Drag;
	}
	void invalidDragClicked() {
		cursorsEx.cursor = Cursor.InvalidDrag;
	}
	void reversedArrowClicked() {
		cursorsEx.cursor = Cursor.ReversedArrow;
	}
	void crosshairClicked() {
		cursorsEx.cursor = Cursor.Crosshair;
	}
	//}}}

	//{{{ file and folder dialogs
	RadioButton textRadio1;
	RadioButton textRadio2;
	RadioButton initRadio1;
	RadioButton initRadio2;
	RadioButton folderRadio1;
	RadioButton folderRadio2;
	RadioButton typeRadio1;
	RadioButton typeRadio2;
	CheckBox multiSelCheck;
	RadioButton folder2Radio1;
	RadioButton folder2Radio2;
	Panel getFileDialogsPanel() {
		auto textLabel = new Label("Text:");
		textRadio1 = new RadioButton("Pick a file, dude");
		textRadio2 = new RadioButton("Invade which file?");
		textRadio1.group = 1;
		textRadio2.group = 1;
		textRadio1.checked = true;

		auto initFileNameLabel = new Label("Initial file name:");
		initRadio1 = new RadioButton("Take cover!");
		initRadio2 = new RadioButton("Run for your lives!");
		initRadio1.group = 2;
		initRadio2.group = 2;
		initRadio1.checked = true;

		auto folderLabel = new Label("Folder:");
		version(Windows) {
			folderRadio1 = new RadioButton(`C:\Program Files`);
			folderRadio2 = new RadioButton(`C:\Windows`);
		} else {
			folderRadio1 = new RadioButton("/usr/lib");
			folderRadio2 = new RadioButton(`/`);
		}
		folderRadio1.group = 3;
		folderRadio2.group = 3;
		folderRadio1.checked = true;

		auto typeLabel = new Label("Type:");
		typeRadio1 = new RadioButton("Open");
		typeRadio2 = new RadioButton("Save");
		typeRadio1.group = 4;
		typeRadio2.group = 4;
		typeRadio1.checked = true;

		multiSelCheck = new CheckBox("Multiple selection");
		// TODO: filters
		auto fileButton = new Button("Open File Dialog");
		fileButton.clicked += &fileButtonClicked;


		auto folder2Label = new Label("Folder:");
		version(Windows) {
			folder2Radio1 = new RadioButton(`C:\Program Files`);
			folder2Radio2 = new RadioButton(`C:\Windows`);
		} else {
			folder2Radio1 = new RadioButton("/usr/lib");
			folder2Radio2 = new RadioButton(`/`);
		}
		folder2Radio1.group = 10;
		folder2Radio2.group = 10;
		folder2Radio1.checked = true;
		auto folderButton = new Button("Open Folder Dialog");
		folderButton.clicked += &folderButtonClicked;

		return mixin(createLayout(`H(*
			V( T[2](
				textLabel V(textRadio1 textRadio2) ~ ~
				initFileNameLabel V(initRadio1 initRadio2) ~ ~
				folderLabel V(folderRadio1 folderRadio2) ~ ~
				typeLabel V(typeRadio1 typeRadio2) ~ ~)
				multiSelCheck
				fileButton)
			*
			V(T[2](folder2Label V(folder2Radio1 folder2Radio2)) folderButton)
			*)`));
	}
	void fileButtonClicked() {
		FileDialog dialog = typeRadio1.checked ? new OpenFileDialog() :
		                                         new SaveFileDialog();

		dialog.text = textRadio1.checked ? textRadio1.text : textRadio2.text;
		dialog.initialFileName = initRadio1.checked ? initRadio1.text : initRadio2.text;
		dialog.folder = folderRadio1.checked ? folderRadio1.text : folderRadio2.text;
		dialog.multipleSelection = multiSelCheck.checked;

		dialog.addFilter("Portable Network Graphics (*.png)", "png");

		if(dialog.showDialog() == DialogResult.OK) {
			Stdout("Clicked OK with files:").newline;
			foreach(f; dialog.files)
				Stdout("    ")(f).newline;
		} else {
			Stdout("Clicked Cancel").newline;
		}
	}
	void folderButtonClicked() {
		auto dialog = new FolderDialog();
		dialog.folder = folder2Radio1.checked ? folder2Radio1.text : folder2Radio2.text;
		if(dialog.showDialog() == DialogResult.OK) {
			Stdout("Clicked OK with folder:").newline;
			Stdout("    ")(dialog.folder).newline;
		} else {
			Stdout("Clicked Cancel").newline;
		}
	}
	//}}}

}
extern(Windows) int MessageBoxW(
	void* hWnd,
	const(wchar)* lpText,
	const(wchar)* lpCaption,
	uint uType
);

void main() {
	Theme.current = Theme.getAll[2];
	Stdout.format("Control size: {} bytes",
		Control.classinfo.init.length).newline;
	Stdout.format("Container size: {} bytes",
		Container.classinfo.init.length).newline;
	Stdout.format("Event size: {} bytes",
		(new Control).painting.sizeof).newline;

	auto win = new Window("Showcase");

	auto notebook = new ShowcaseNotebook;
	win.content = mixin(createLayout("H(notebook)"));
	win.content.size = Size(640, 360);

	win.visible = true;
	win.position = Position.Center;
	Application.run(win);
}

