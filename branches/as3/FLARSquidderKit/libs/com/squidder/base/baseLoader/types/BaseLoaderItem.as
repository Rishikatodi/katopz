package com.squidder.base.baseLoader.types {	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IOErrorEvent;	import flash.events.ProgressEvent;		import com.squidder.base.baseLoader.BaseLoaderProperties;		/**	 * This is our basic loader item. All items extend this class.	 * @author Jon Reiling	 */	public class BaseLoaderItem extends EventDispatcher {				protected var _url : String;		protected var _props : BaseLoaderProperties;		protected var _content : *;		/**		 * Item constructor.		 * @param url URL of the item.		 * @param props Properties, if any, of the item.		 */		public function BaseLoaderItem( url : String , props : BaseLoaderProperties ) {						_url = url;			_props = props;		}		/**		 * Begin loading the item.		 */		public function load() : void {		}		/**		 * Return the content of the item.		 */		public function get content() : * {						return _content;			}		/**		 * Clean out the item.		 */		public function clean() : void {								}				/**		 * Return the url of the BaseLoaderItem.		 */		public function get url() : String {						return _url;			}		/**		 * Set the content of the item for access.		 */		protected function _setContent() : void {		}		/**		 * Handle when the item has loaded.		 */		protected function _handleComplete( event : Event ) : void {						_setContent( );			dispatchEvent( new Event( Event.COMPLETE ) );		}		/**		 * Handle item load progress.		 */		protected function _handleProgress( event : ProgressEvent ) : void {						var ev : ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS );			ev.bytesLoaded = event.bytesLoaded;			ev.bytesTotal = event.bytesTotal;						dispatchEvent( ev );		}				/**		 * Handle any item errors.		 */		protected function _handleError( event : IOErrorEvent ) : void {			dispatchEvent( event );					}	}}