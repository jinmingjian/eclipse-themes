package net.jeeeyul.eclipse.themes.preference

import net.jeeeyul.eclipse.themes.SharedImages
import net.jeeeyul.eclipse.themes.css.DragHandleFactory
import net.jeeeyul.eclipse.themes.ui.ColorPicker
import net.jeeeyul.eclipse.themes.ui.ColorWell
import net.jeeeyul.eclipse.themes.ui.HSB
import net.jeeeyul.eclipse.themes.ui.SWTExtensions
import org.eclipse.jface.dialogs.IDialogConstants
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.GC
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.Event
import org.eclipse.swt.widgets.ToolBar

import static net.jeeeyul.eclipse.themes.preference.ChromeConstants.*

class ToolbarPage extends ChromePage {
	extension SWTExtensions = new SWTExtensions
	
	ColorWell toolBarStartColorWell
	ColorWell toolBarEndColorWell
	ColorWell perspectiveStartColorWell
	ColorWell perspectiveEndColorWell
	ColorWell perspectiveOutlineColorWell
	Button useWBColorAsPerspectiveColorButton;
	Composite previewWrap
	Composite previewBar
	ToolBar perspectiveBar
	
	
	Button engravedButton
	Button embossedButton
	
	Button useTrimStackBorderButton
	
	new(){
		super("Toolbar", SharedImages::TOOLBAR)
	}

	override create(Composite parent) {
		parent => [
			layout = newGridLayout
			
			newLabel[
				text = "Configurations for main tool bar and Perspective Switcher"
			]
			
			previewWrap = newCompositeWithStyle(SWT::DOUBLE_BUFFERED || SWT::BORDER)[
				layoutData = FILL_HORIZONTAL
				layout = newGridLayout[
					makeColumnsEqualWidth = false
					numColumns = 2
					marginWidth = 3
					marginHeight = 3
				]
				
				onPaint = [
					renderPreview(it)
				]
				
				previewBar = newComposite[
					layoutData = FILL_HORIZONTAL
					layout = newGridLayout[
						marginWidth = 0
						marginHeight = 0
						numColumns = 4
						horizontalSpacing = 1
					]
					onResize = [
						updateToolbarBackgroundImage()
					]
					
					newComposite[
						layoutData = newGridData[
							widthHint = 5
							heightHint = 20
						]
						onPaint = [renderHandle]
					]
					
					newToolBar(SWT::FLAT || SWT::RIGHT)[
						newToolItem(SWT::DROP_DOWN)[
							it.image = SharedImages::getImage(SharedImages::ECLIPSE)
						]
					]
					
					newComposite[
						layoutData = newGridData[
							widthHint = 5
							heightHint = 20
						]
						onPaint = [renderHandle]
					]
					
					newToolBar(SWT::FLAT || SWT::RIGHT)[
						newToolItem[
							it.image = SharedImages::getImage(SharedImages::ECLIPSE)
						]
						newToolItem[
							it.image = SharedImages::getImage(SharedImages::TOOLBAR)
						]
					]
				]
				
				
				perspectiveBar = newToolBar(SWT::RIGHT || SWT::FLAT)[
					onResize = [updatePerspectiveBarBackgroundImage()]
					newToolItem[
						it.image = SharedImages::getImage(SharedImages::OPEN_PERSPECTIVE)
					]
					newToolItem(SWT::^SEPARATOR)[]
					newToolItem[
						it.image = SharedImages::getImage(SharedImages::PLUGIN)
						it.text = "Plug-in Development"
					]
				]
			]
			newGroup[
				layout = newGridLayout[
					numColumns = 3
				]
				text = "Main Tool Bar"
				layoutData = FILL_HORIZONTAL
				newLabel[
					text = "Start Color"
				]
				toolBarStartColorWell = newColorWell[
					onSelection = [updatePreview]
				]
				newPushButton[
					text = "Change"
					onClick = [
						toolBarStartColorWell.showColorPicker()
					]
				]
				newLabel[
					text = "End Color"
				]
				toolBarEndColorWell = newColorWell[
					onSelection = [updatePreview]
				]
				newPushButton[
					text = "Change"
					onClick = [
						toolBarEndColorWell.showColorPicker()
					]
				]
			]
			newGroup[
				layout = newGridLayout[
					numColumns = 4
				]
				text = "Perspective Switcher"
				layoutData = FILL_HORIZONTAL
				newLabel[
					text = "Start Color"
				]
				perspectiveStartColorWell = newColorWell[
					onSelection = [updatePreview]
				]
				newPushButton[
					text = "Change"
					layoutData = newGridData[
						horizontalSpan = 2
					]
					onClick = [
						perspectiveStartColorWell.showColorPicker()
					]
				]
				newLabel[
					text = "End Color"
				]
				perspectiveEndColorWell = newColorWell[
					onSelection = [updatePreview]
				]
				newPushButton[
					text = "Change"
					onClick = [
						perspectiveEndColorWell.showColorPicker()
					]
				]
				useWBColorAsPerspectiveColorButton = newCheckbox[
					text = "Use Window Background"
					onSelection = [
						updateAutoColors()
						updateEnablement()
					]
				]
				newLabel[
					text = "Outline Color"
				]
				perspectiveOutlineColorWell = newColorWell[
					onSelection = [updatePreview]
				]
				newPushButton[
					layoutData = newGridData[
						horizontalSpan = 2
					]
					text = "Change"
					onClick = [
						perspectiveOutlineColorWell.showColorPicker()
					]
				]
			]// Group
			
			newGroup[
				text = "Drag Handle && Stack Border"
				layout = newGridLayout[
					numColumns = 3
				]
				layoutData = FILL_HORIZONTAL
				
				newLabel[
					text = "Handle Type:"
				]				
				
				engravedButton = newRadioButton[
					text = "Engraved"
					onSelection = [
						updatePreview()
					]
				]
				
				embossedButton = newRadioButton[
					text = "Embossed"
					onSelection = [
						updatePreview()
					]
				]
				
				useTrimStackBorderButton = newCheckbox[
					text = "Use image border for trim stack."
					layoutData = newGridData[
						horizontalSpan = 3
					]
				]
			]//end
			
			newLabel[
				text = "New workbench window needs to be open to update handles."
			]
		]
	}
	
	def renderHandle(Event e){
		var data = new DragHandleFactory().create(e.height, toolBarStartColorWell.selection, embossedButton.selection)
		var image = new Image(display, data)
		e.gc.drawImage(image, 0, 0);
		image.dispose()
	}

	def updateAutoColors() {
		if(useWBColorAsPerspectiveColorButton.selection) {
			perspectiveEndColorWell.selection = getCompanionPage(typeof(GeneralPage)).windowBackgroundColorWell.selection
		}
	}

	def void updateEnablement() {
		perspectiveEndColorWell.next.enabled = !useWBColorAsPerspectiveColorButton.selection
	}
	
	def Control next(Control control){
		var index = control.parent.children.indexOf(control)
		return control.parent.children.get(index + 1)
	}

	def void renderPreview(Event e) {
		var rect = previewWrap.clientArea
		rect.width = previewBar.bounds.width + previewBar.bounds.x
		var start = new Color(getTabFolder.display, toolBarStartColorWell.selection.toRGB)
		var end = new Color(getTabFolder.display, toolBarEndColorWell.selection.toRGB)
		var outline = new Color(getTabFolder.display, perspectiveOutlineColorWell.selection.toRGB)
		e.gc.foreground = start
		e.gc.background = end
		e.gc.fillGradientRectangle(rect.x, rect.y, rect.width, rect.height, true)
		e.gc.foreground = outline
		e.gc.drawLine(rect.x, rect.y + rect.height-1, rect.x + rect.width,  rect.y + rect.height-1);
		e.gc.drawLine(rect.x + rect.width,  rect.y, rect.x + rect.width,  rect.y + rect.height-1);
		start.safeDispose()
		end.safeDispose()
		outline.safeDispose()
		rect = previewWrap.clientArea
		rect.width = perspectiveBar.bounds.width + 7
		rect.x = perspectiveBar.bounds.x - 4
		start = new Color(getTabFolder.display, perspectiveStartColorWell.selection.toRGB)
		end = new Color(getTabFolder.display, perspectiveEndColorWell.selection.toRGB)
		e.gc.foreground = start
		e.gc.background = end
		e.gc.fillGradientRectangle(rect.x, rect.y, rect.width, rect.height, true)
		start.safeDispose()
		end.safeDispose()
	}

	def private void updatePreview() {
		previewWrap.redraw()
		updateToolbarBackgroundImage()
		updatePerspectiveBarBackgroundImage()
	}

	def private void updateToolbarBackgroundImage(){
		var size = previewBar.size
		if(size.x <= 0 || size.y <=0) {
			return
		}
		previewBar.backgroundImage.safeDispose()
		var image = new Image(getTabFolder.display, 20, size.y)
		var gc = new GC(image)
		var start = new Color(getTabFolder.display, toolBarStartColorWell.selection.toRGB)
		var end = new Color(getTabFolder.display, toolBarEndColorWell.selection.toRGB)
		gc.foreground = start
		gc.background = end
		gc.fillGradientRectangle(0, -3, size.x, size.y+6, true)
		start.dispose()
		end.dispose()
		gc.dispose()
		previewBar.backgroundImage = image
	}

	def private void updatePerspectiveBarBackgroundImage(){
		var size = previewBar.size
		if(size.y <=0) {
			return
		}
		perspectiveBar.backgroundImage.safeDispose()
		var image = new Image(getTabFolder.display, 20, size.y)
		var gc = new GC(image)
		var start = new Color(getTabFolder.display, perspectiveStartColorWell.selection.toRGB)
		var end = new Color(getTabFolder.display, perspectiveEndColorWell.selection.toRGB)
		gc.foreground = start
		gc.background = end
		gc.fillGradientRectangle(0, -3, size.x, size.y+6, true)
		start.dispose()
		end.dispose()
		gc.dispose()
		perspectiveBar.backgroundImage = image
	}

	override dispose() {
		previewBar.backgroundImage.safeDispose()
		perspectiveBar.backgroundImage.safeDispose()
	}

	override load(IPreferenceStore store) {
		toolBarStartColorWell.selection = new HSB(
			store.getFloat(CHROME_TOOLBAR_START_HUE),
			store.getFloat(CHROME_TOOLBAR_START_SATURATION), 
			store.getFloat(CHROME_TOOLBAR_START_BRIGHTNESS)
		)
		toolBarEndColorWell.selection = new HSB(
			store.getFloat(CHROME_TOOLBAR_END_HUE),
			store.getFloat(CHROME_TOOLBAR_END_SATURATION), 
			store.getFloat(CHROME_TOOLBAR_END_BRIGHTNESS)
		)
		perspectiveStartColorWell.selection = new HSB(
			store.getFloat(CHROME_PERSPECTIVE_START_HUE),
			store.getFloat(CHROME_PERSPECTIVE_START_SATURATION), 
			store.getFloat(CHROME_PERSPECTIVE_START_BRIGHTNESS)
		)
		perspectiveEndColorWell.selection = new HSB(
			store.getFloat(CHROME_PERSPECTIVE_END_HUE),
			store.getFloat(CHROME_PERSPECTIVE_END_SATURATION), 
			store.getFloat(CHROME_PERSPECTIVE_END_BRIGHTNESS)
		)
		perspectiveOutlineColorWell.selection = new HSB(
			store.getFloat(CHROME_PERSPECTIVE_OUTLINE_HUE),
			store.getFloat(CHROME_PERSPECTIVE_OUTLINE_SATURATION), 
			store.getFloat(CHROME_PERSPECTIVE_OUTLINE_BRIGHTNESS)
		)
		useWBColorAsPerspectiveColorButton.selection = store.getBoolean(CHROME_USE_WINDOW_BACKGROUND_COLOR_AS_PERSPECTIVE_END_COLOR)
		
		
		embossedButton.selection = store.getBoolean(CHROME_USE_EMBOSSED_DRAG_HANDLE)
		engravedButton.selection = !store.getBoolean(CHROME_USE_EMBOSSED_DRAG_HANDLE)
		useTrimStackBorderButton.selection = store.getBoolean(CHROME_USE_TRIMSTACK_IMAGE_BORDER)
		
		updateAutoColors()
		updateEnablement()
		updatePreview()
	}

	override save(IPreferenceStore store) {
		store.setValue(CHROME_TOOLBAR_START_HUE, toolBarStartColorWell.selection.hue)
		store.setValue(CHROME_TOOLBAR_START_SATURATION, toolBarStartColorWell.selection.saturation)
		store.setValue(CHROME_TOOLBAR_START_BRIGHTNESS, toolBarStartColorWell.selection.brightness)
		store.setValue(CHROME_TOOLBAR_END_HUE, toolBarEndColorWell.selection.hue)
		store.setValue(CHROME_TOOLBAR_END_SATURATION, toolBarEndColorWell.selection.saturation)
		store.setValue(CHROME_TOOLBAR_END_BRIGHTNESS, toolBarEndColorWell.selection.brightness)
		store.setValue(CHROME_PERSPECTIVE_START_HUE, perspectiveStartColorWell.selection.hue)
		store.setValue(CHROME_PERSPECTIVE_START_SATURATION, perspectiveStartColorWell.selection.saturation)
		store.setValue(CHROME_PERSPECTIVE_START_BRIGHTNESS, perspectiveStartColorWell.selection.brightness)
		store.setValue(CHROME_PERSPECTIVE_END_HUE, perspectiveEndColorWell.selection.hue)
		store.setValue(CHROME_PERSPECTIVE_END_SATURATION, perspectiveEndColorWell.selection.saturation)
		store.setValue(CHROME_PERSPECTIVE_END_BRIGHTNESS, perspectiveEndColorWell.selection.brightness)
		store.setValue(CHROME_PERSPECTIVE_OUTLINE_HUE, perspectiveOutlineColorWell.selection.hue)
		store.setValue(CHROME_PERSPECTIVE_OUTLINE_SATURATION, perspectiveOutlineColorWell.selection.saturation)
		store.setValue(CHROME_PERSPECTIVE_OUTLINE_BRIGHTNESS, perspectiveOutlineColorWell.selection.brightness)
		
		store.setValue(CHROME_USE_WINDOW_BACKGROUND_COLOR_AS_PERSPECTIVE_END_COLOR, useWBColorAsPerspectiveColorButton.selection)
		
		store.setValue(CHROME_USE_EMBOSSED_DRAG_HANDLE, embossedButton.selection)
		store.setValue(CHROME_USE_TRIMSTACK_IMAGE_BORDER, useTrimStackBorderButton.selection)
	}

	override setToDefault(IPreferenceStore store) {
		toolBarStartColorWell.selection = new HSB(
			store.getDefaultFloat(CHROME_TOOLBAR_START_HUE),
			store.getDefaultFloat(CHROME_TOOLBAR_START_SATURATION), 
			store.getDefaultFloat(CHROME_TOOLBAR_START_BRIGHTNESS)
		)
		toolBarEndColorWell.selection = new HSB(
			store.getDefaultFloat(CHROME_TOOLBAR_END_HUE),
			store.getDefaultFloat(CHROME_TOOLBAR_END_SATURATION), 
			store.getDefaultFloat(CHROME_TOOLBAR_END_BRIGHTNESS)
		)
		perspectiveStartColorWell.selection = new HSB(
			store.getDefaultFloat(CHROME_PERSPECTIVE_START_HUE),
			store.getDefaultFloat(CHROME_PERSPECTIVE_START_SATURATION), 
			store.getDefaultFloat(CHROME_PERSPECTIVE_START_BRIGHTNESS)
		)
		perspectiveEndColorWell.selection = new HSB(
			store.getDefaultFloat(CHROME_PERSPECTIVE_END_HUE),
			store.getDefaultFloat(CHROME_PERSPECTIVE_END_SATURATION), 
			store.getDefaultFloat(CHROME_PERSPECTIVE_END_BRIGHTNESS)
		)
		perspectiveOutlineColorWell.selection = new HSB(
			store.getDefaultFloat(CHROME_PERSPECTIVE_OUTLINE_HUE),
			store.getDefaultFloat(CHROME_PERSPECTIVE_OUTLINE_SATURATION), 
			store.getDefaultFloat(CHROME_PERSPECTIVE_OUTLINE_BRIGHTNESS)
		)
		useWBColorAsPerspectiveColorButton.selection = store.getDefaultBoolean(CHROME_USE_WINDOW_BACKGROUND_COLOR_AS_PERSPECTIVE_END_COLOR)
		
		
		embossedButton.selection = store.getDefaultBoolean(CHROME_USE_EMBOSSED_DRAG_HANDLE)
		engravedButton.selection = !store.getDefaultBoolean(CHROME_USE_EMBOSSED_DRAG_HANDLE)
		useTrimStackBorderButton.selection = store.getDefaultBoolean(CHROME_USE_TRIMSTACK_IMAGE_BORDER)
	
		
		updateAutoColors()
		updateEnablement()
		updatePreview()
	}

	def private void showColorPicker(ColorWell well) {
		var picker = new ColorPicker()
		var original = well.selection
		picker.selection = well.selection
		picker.continuosSelectionHandler = [
			well.selection = it
		]
		if(well.getData("lock-hue") == true) {
			picker.lockHue = true
		}
		if(picker.open() == IDialogConstants::OK_ID) {
			well.selection = picker.selection
		} else {
			well.selection = original
		}
	}
}